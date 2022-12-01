
SELECT
    contract_object_id = IP.OBJECT_ID,
	business_id = ISNULL(RTRIM(LTRIM(BUS.IDENTIFIER)), 'Not Defined'),
    insured_period_from = ISNULL(BS.INSRD_PERIOD_START, '1900-01-01'),
    insured_period_to = ISNULL(BS.INSRD_PERIOD_END, '1900-01-01'),
	nb_of_days = DATEDIFF(DAY, ISNULL(BS.INSRD_PERIOD_START, '1900-01-01'), ISNULL(BS.INSRD_PERIOD_END, '1900-01-01')),
    underwriting_year = ISNULL(IP.UNDERWR_YEAR, 1900),   
    business_title = ISNULL(LTRIM(RTRIM(BUS.TITLE)), 'Not Defined'),
    business_in_force_yn = CASE
                               WHEN ISNULL(BS.INSRD_PERIOD_END, '1900-01-01') >= GETDATE()
                               AND ISNULL(BS.INSRD_PERIOD_START, '1900-01-01') <= GETDATE()
                               AND ISNULL(RTRIM(BS.ABS_CURR_REF_NM), 'Not Defined') = 'Definite' THEN
                                   'Y'
                               ELSE
                                   'N'
                           END,
    level_of_business_code = ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined'),
    type_of_business_code = ISNULL(RTRIM(BUS.FRK_TYPE_OF_BUS), 'Not Defined'),
    agreement_basic_status_current = ISNULL(BS.ABS_CURR_REF_NM, 'Not Defined'),
    agreement_status_current = ISNULL(BS.ALCS_CURR_REF_NM, 'Not Defined')
FROM INSURED_PERIOD IP
LEFT JOIN BUS_STRUCT_REP BS
    ON BS.FK_INS_PERIOD = IP.OBJECT_ID
    AND BS.SOC_IS_ACTIVE = 'Y'
    AND BS.HIERARCHY_LEVEL = 1
    AND BS.SOC_SUBCLASS
    BETWEEN 2 AND 5
    AND BS.IS_CURRENT_LCP = 'Y'
LEFT OUTER JOIN BUSINESS BUS
    ON BS.FK_BUSINESS = BUS.OBJECT_ID
WHERE ISNULL(IP.UNDERWR_YEAR, 1900) >= 2020
AND ISNULL(BS.ABS_CURR_REF_NM, 'Not Defined') = 'Definite'
AND DATEDIFF(DAY, ISNULL(BS.INSRD_PERIOD_START, '1900-01-01'), ISNULL(BS.INSRD_PERIOD_END, '1900-01-01')) NOT BETWEEN 363 AND 367
ORDER BY
    ISNULL(RTRIM(LTRIM(BUS.IDENTIFIER)), 'Not Defined'),
    ISNULL(BS.INSRD_PERIOD_START, '1900-01-01')