################################################
#NAME    : shutterfly_CLV.R
#DATE    : 31-JAN-2017
#DESC    : This program in R will be used to calculate the Customer Lifetime Value
#        : More details about the problem are available @ https://github.com/sflydwh/code-challenge
#VERSION : 0.1 Initial version
################################################
#including the jsonlite library
library(jsonlite)

#Reading the sample JSON file as a data.frame from local storage
sfly_input <- fromJSON("sample.json")

#Subsetting customer data into a separate data.frame
customer <- subset(sfly_input, type == "CUSTOMER")

#Subsetting site visit data into a separate data.frame
site_visit <- subset(sfly_input, type == "SITE_VISIT")

#Subsetting image data into a separate data.frame
image <- subset(sfly_input, type == "IMAGE")

#Subsetting order data into a separate data.frame
order <- subset(sfly_input, type =="ORDER")

#Selecting a customer subset with only name and customer_id
cust_subset <- subset(customer, select = c("key","last_name"))
colnames(cust_subset) <- c("customer_id", "last_name")

#Count of site visit for each customer
stevstcnt <- count(site_visit, "customer_id")

#Provide meaningful column names for stevstcnt
colnames(stevstcnt) <- c("customer_id", "stevstcnt")

#Join cust_subset and stevstcnt by customer_id
cust_stats <- unique(join(cust_subset, stevstcnt, by = "customer_id", type="inner"))

#Join cust_stats and sum_exp
cust_stats <- unique(join(cust_stats, sum_exp, by="customer_id", type="inner"))
colnames(cust_stats) <- c("customer_id", "last_name", "cnt_ste_vst", "sum_exp")

#join cust_stats and avg_exp
cust_stats <- unique(join(cust_stats, avg_exp, by="customer_id", type="inner"))
colnames(cust_stats) <- c("customer_id", "last_name", "cnt_ste_vst", "sum_exp","avg_exp")

##adding new column to df cust_stats["avt_cust_val"] <- cust_stats$cnt_ste_vst * cust_stats$avg_exp
##

#Calculating average customer value per week
cust_stats["avt_cust_val"] <- cust_stats$cnt_ste_vst * cust_stats$avg_exp

#Calculating simple LTV
simple_LTV <- 52*mean(cust_stats$avt_cust_val)*10