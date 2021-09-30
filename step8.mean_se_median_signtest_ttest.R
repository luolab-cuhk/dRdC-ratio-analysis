rm(list=ls())

# data input
args<-commandArgs(TRUE)
dat<-read.table(args[1], header=T)

# median
print("median")
median(dat$ratio_target)
median(dat$ratio_control)

# mean
print("mean")
mean(dat$ratio_target)
mean(dat$ratio_control)

# standard error
print("se")
sd(dat$ratio_target)/sqrt(length(dat$ratio_target))
sd(dat$ratio_control)/sqrt(length(dat$ratio_control))

# ds comparison
num_target_lg<-length(which(dat$ratio_target>dat$ratio_control))
num_control_lg<-length(which(dat$ratio_target<dat$ratio_control))
num_sum<-num_target_lg+num_control_lg
# binomial test
binom.test(num_target_lg,num_sum,alternative="greater")

# t test
t.test(dat$ratio_target, dat$ratio_control, paired=TRUE, alternative="greater")
