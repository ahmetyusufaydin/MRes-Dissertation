import excel "$Data\ASSET4.xlsx", sheet("PublicHealth") firstrow clear

drop A SourceDate Title URL Abstract K L M N Rec

replace FY = subinstr(FY,"FY","",.)

destring FY Pub, replace force

gen IPub=1 if Pub!=.

gen c=1 if IPub==1

egen TPub=total(IPub)

duplicates drop ISIN c, force

egen cont=sum(c)


drop if missing(c)

save "$Data\built\publich.dta", replace