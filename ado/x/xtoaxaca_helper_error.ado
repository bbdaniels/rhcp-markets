* ********************************** *
* Program for Error messages ******* *
* ********************************** *
cap program drop xtoaxaca_helper_Error
program define xtoaxaca_helper_Error
    args nr txt
    dis as err `"{p}`txt'{p_end}"'
    exit `nr'
end






