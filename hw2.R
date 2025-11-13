#!/usr/bin/env Rscript

Sys.setlocale(category = "LC_ALL", locale = "C.UTF-8")

if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl", repos = "https://cloud.r-project.org")
}
library(readxl)

INPUT_PATH  <- Sys.getenv("INPUT_PATH",  unset = "./common/Пациенты.xlsx")
OUTPUT_DIR  <- Sys.getenv("OUTPUT_DIR",  unset = "/output")
if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)
OUTPUT_CSV  <- file.path(OUTPUT_DIR, "анализ_гемоглобина.csv")
OUTPUT_PNG  <- file.path(OUTPUT_DIR, "boxplot_глюкоза_по_полу.png") 

patients <- read_excel(INPUT_PATH)
getwd()

#1.
str(patients$Возраст) #num
str(patients$глюкоза) #num

#2
patients$Пол <- factor(patients$Пол, levels = c("м", "ж"))
str(patients$Пол) #chr 

#3 
patients$возраст_группа_2 <- cut(patients$Возраст, 
                                 breaks = c(-Inf, 60, Inf), 
                                 labels = c("Молодые", "Старшие"))
#4
patients[patients$Возраст > 75, ]

#5 
head(patients$лейкоциты) #[1] 13.9  4.6  8.7  6.2  5.7  4.1
head(patients$глюкоза) #[1] 25.1  5.4  4.8  5.5  5.5 16.7
summary(patients$лейкоциты) # Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#                          3.000   6.200   7.600   8.069   9.400  17.400 
summary(patients$глюкоза)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#4.200   5.400   5.800   6.539   6.700  26.700 

#6 
aggregate(глюкоза ~ Пол, data = patients, FUN = mean)
#Пол  глюкоза
#1   ж 6.841121
#2   м 6.404896

#7.
aggregate(лейкоциты ~ Пол + возраст_группа_2, data = patients, FUN = mean)
#  Пол возраст_группа_2 лейкоциты
#1   ж          Молодые  8.071429
#2   м          Молодые  8.304478
#3   ж          Старшие  7.532639
#4   м          Старшие  8.133645

#8 
aggregate(глюкоза ~ Пол, data = patients, FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
#   Пол глюкоза.mean глюкоза.sd  глюкоза.n
#1   ж     6.841121   3.310702 107.000000
#2   м     6.404896   2.160624 241.000000

#9 см.8 

#10 (сохраняем в PNG вместо окна)
png(OUTPUT_PNG, width = 1000, height = 700, res = 150)
boxplot(глюкоза ~ Пол, data = patients, main = 'Распределение глюкозы по полу', xlab = "Пол", ylab = "Уровень глюкозы")
dev.off()

#11
t.test(лейкоциты ~ Пол, data = patients)

#12
patients_task <- patients
patients_task$глюкоза[c(3, 15, 45)] <- NA

sum(is.na(patients_task)) #3

#13 
which(is.na(patients_task$глюкоза)) #3, 15, 45

#14 
patients_no_na <- na.omit(patients_task)
dim(patients_task) #348  10
dim(patients_no_na) #345  10

#15 
patients_task$глюкоза[is.na(patients_task$глюкоза)] <- median(patients_task$глюкоза, na.rm = TRUE)

#16 
aggregate(лейкоциты ~ Пол, data = patients_task, FUN = mean, na.rm = TRUE)
#  Пол лейкоциты
#1   ж  7.708879
#2   м  8.228631
aggregate(лейкоциты ~ Пол, data = patients_no_na, FUN = mean)

#Пол лейкоциты
#1   ж  7.725481
#2   м  8.228631

#17 
final_result <- aggregate(гемоглобин ~ возраст_группа_2, data = patients, FUN = function(x) c(mean = mean(x), sd = sd(x)))
colnames(final_result) <- c("Возрастная группа", "Среднее и стандартное отклонение")

#18 — пишем CSV в смонтированную папку на сервере
write.csv(final_result, OUTPUT_CSV, row.names = FALSE, fileEncoding = "UTF-8")

cat(sprintf("CSV сохранён: %s\nГрафик сохранён: %s\n", OUTPUT_CSV, OUTPUT_PNG))
