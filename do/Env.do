import excel "$Data\ASSET4.xlsx", sheet("Env") firstrow clear

drop A SourceDate Title URL Abstract K L M N Rec

replace FY = subinstr(FY,"FY","",.)

destring FY Env, replace force
*destring Rec, replace force

gen IEnv=1 if Env!=.
*gen IRec=1 if Rec!=.

gen c=1 if IEnv==1 //| IRec==1

egen TEnv=total(IEnv)
*egen TRec=total(IRec)

duplicates drop ISIN c, force

egen cont=sum(c)


drop if missing(c)

save "$Data\built\env.dta", replace

