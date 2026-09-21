# Run from repository root: Rscript scripts/run_analysis.R
# Reproduces the July 20, 2026 sample and adds a September 2026 data audit.
suppressPackageStartupMessages(library(ggplot2))
dir.create("results", showWarnings=FALSE); dir.create("figures", showWarnings=FALSE)
food <- read.csv("data/price_of_healthy_diet_clean.csv", stringsAsFactors=FALSE, na.strings=c("", "NA"))
w <- read.csv("data/world_bank_indicators.csv", stringsAsFactors=FALSE, check.names=FALSE, na.strings=c("..", "", "NA"))
names(w) <- c("country","country_code","year","time_code","gdp","inflation","exchange_rate","agriculture_share","trade_share","population","urban_share","poverty","unemployment")
# Discard export footer rows with no numeric year; preserve count in audit.
w$year <- suppressWarnings(as.integer(w$year)); footer_rows <- sum(is.na(w$year)); w <- w[!is.na(w$year),]
w$country[w$country=="Egypt, Arab Rep."] <- "Egypt"
for (v in c("gdp","inflation","exchange_rate","agriculture_share","trade_share","population","urban_share")) w[[v]] <- as.numeric(w[[v]])
stopifnot(!anyDuplicated(food[c("country","year")]), !anyDuplicated(w[c("country","year")]))
countries <- c("India","Indonesia","Philippines","Mexico","Brazil","Kazakhstan","South Africa","Colombia","Peru","Thailand","Malaysia","Egypt")
f <- food[food$country %in% countries, ]
w$matched_wdi <- TRUE
panel <- merge(f[c("country","year","cost_healthy_diet_ppp_usd","data_quality")], w[c("country","year","gdp","inflation","exchange_rate","agriculture_share","trade_share","population","urban_share","matched_wdi")], by=c("country","year"), all.x=TRUE, sort=TRUE)
stopifnot(nrow(panel)==nrow(f), nrow(panel)==96, length(unique(panel$country))==12, all(panel$matched_wdi %in% TRUE))
write.csv(panel,"results/selected_panel.csv",row.names=FALSE)
vars <- c("cost_healthy_diet_ppp_usd","gdp","inflation","exchange_rate","agriculture_share","trade_share","population","urban_share")
desc <- do.call(rbind,lapply(vars,function(v){x<-panel[[v]]; data.frame(variable=v,observations=sum(!is.na(x)),mean=mean(x,na.rm=TRUE),sd=sd(x,na.rm=TRUE),minimum=min(x,na.rm=TRUE),maximum=max(x,na.rm=TRUE))}))
write.csv(desc,"results/descriptive_statistics.csv",row.names=FALSE)
# Validate only selected-country regions against an explicit geographic lookup.
lookup <- data.frame(country=countries, expected_region=c("Asia","Asia","Asia","Americas","Americas","Asia","Africa","Americas","Americas","Asia","Asia","Africa"))
regions <- merge(unique(f[c("country","region")]),lookup,by="country")
regions$mismatch <- regions$region != regions$expected_region
write.csv(regions,"results/region_audit.csv",row.names=FALSE)
quality <- as.data.frame(table(food$data_quality)); names(quality)<-c("quality_label","records")
write.csv(quality,"results/source_quality_labels.csv",row.names=FALSE)
changes <- do.call(rbind,lapply(split(panel,panel$country),function(d){a<-d$cost_healthy_diet_ppp_usd[d$year==2017];b<-d$cost_healthy_diet_ppp_usd[d$year==2024];data.frame(country=d$country[1],cost_2017=a,cost_2024=b,percent_change=100*(b/a-1))}))
write.csv(changes,"results/endpoint_changes.csv",row.names=FALSE)
p <- ggplot(panel,aes(year,cost_healthy_diet_ppp_usd)) + geom_line(color="#24618C",linewidth=.7) + geom_point(color="#24618C",size=1) + facet_wrap(~country,ncol=3) + theme_minimal(base_size=10) + labs(title="Healthy diet cost in the supplied project data",subtitle="Descriptive reproduction; source vintage and PPP basis require verification",x=NULL,y="Reported daily cost (PPP dollars)",caption="All supplied food-cost records carry the label Estimated value. Regional labels are excluded.")
ggsave("figures/country_trends.png",p,width=10,height=8,dpi=160)
writeLines(c(paste("Food input rows:",nrow(food)),paste("WDI valid-year rows:",nrow(w)),paste("WDI footer rows removed:",footer_rows),paste("Selected panel rows:",nrow(panel)),paste("Region mismatches among selected countries:",sum(regions$mismatch)),"No causal estimate is computed: no treatment, intervention date, or identification design was supplied."),"results/audit_summary.txt")
capture.output(sessionInfo(),file="results/session_info.txt")
print(desc); print(regions); print(changes)
