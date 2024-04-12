


cap program drop xtoaxaca_helper_blocks
program define xtoaxaca_helper_blocks
syntax, blocks(string) model(name) [save]


	local block_rest "`blocks'"
	local i = 1

	while "`block_rest'" != "" {
		gettoken  blocks`i' block_rest: block_rest, parse(",") bind
		if "`blocks`i''" != "," {
			local ++i
		}
	}

	local num_blocks = `i'-1

	***** start reading out *****


	**** loop over different blocks ***

	local all_sum_blockvars ""

	forvalues X = 1/`num_blocks' {


		local b`X'brest = "`blocks`X''"

		forvalues Z = 1/3 {
			gettoken  b`X'newblock`Z' b`X'brest: b`X'brest, parse("=") bind
		}

		** delete parantheses ***

		local b`X'newblock_d = subinstr("`b`X'newblock3'",")","",.)
		local b`X'newblock_d = subinstr("`b`X'newblock_d'","(","",.)
		

		** count words ***

		local b`X'n_block_vars = wordcount("`b`X'newblock_d'")
		*dis `b`X'n_block_vars'

		*** new local based on c./i.***

		tokenize `b`X'newblock_d'


		local b`X'sum_blockvars ""
		forvalues Y = 1/`b`X'n_block_vars' {
			
			*** determine whether i/c
			qui est restore `model'
			local reqs2: colnames e(b)
			xtoaxaca_helper_is_factor, reqs(`reqs2') variable(``Y'')
			local fv_i_``Y'' = r(is_factor)
			
			if "`fv_i_``Y'''" == "1" {
				local b`X'sum_blockvars "`b`X'sum_blockvars' ``Y''_*"
			}
			else if "`fv_i_``Y'''" == "0" {
				local b`X'sum_blockvars "`b`X'sum_blockvars' ``Y''"
			}
			
		}
		



		**** generate the new variable ****
		cap drop `b`X'newblock1'
		egen `b`X'newblock1' = rowtotal(`b`X'sum_blockvars')
		
		local all_sum_blockvars "`all_sum_blockvars' `b`X'sum_blockvars'"
		move `b`X'newblock1' Total
	}
	
	if "`save'" == "" {
		drop `all_sum_blockvars'
	}

end


