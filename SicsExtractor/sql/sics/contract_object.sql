SET NOCOUNT ON;
DROP TABLE IF EXISTS #level_of_business;
SET NOCOUNT ON;
SELECT
    BUS.OBJECT_ID,
    level_of_business_code = ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined'),
    level_of_business = ISNULL(RTRIM(rdlob.NAME), 'Not Defined')
INTO #level_of_business
FROM BUSINESS BUS
JOIN REFERENCE_DATA rdlob
    ON rdlob.CODE = BUS.FRK_LEVEL_OF_BUS
    AND rdlob.SUBCLASS = 45;

SET NOCOUNT ON;
DROP TABLE IF EXISTS #type_of_participation;
SET NOCOUNT ON;
SELECT
    DISTINCT -- added distinct 2011-08-16    
    ip.OBJECT_ID,
    name = LTRIM(RTRIM(rd.NAME)),
    code = LTRIM(RTRIM(CAST(rd.CODE AS VARCHAR(15))))
INTO #type_of_participation
FROM INSURED_PERIOD ip
JOIN BUSINESS b
    ON ip.FK_BUSINESS = b.OBJECT_ID
JOIN BUS_STRUCT_REP BRT
    ON ip.OBJECT_ID = BRT.FK_INS_PERIOD
JOIN BUS_CLASSIFIC bc
    ON bc.OBJECT_ID = BRT.FK_SOC_CLASSIFIC
INNER JOIN CLASSIF_REF_DATA c
    ON c.FK_CLASSIFICATION = bc.OBJECT_ID
INNER JOIN REFERENCE_DATA rd
    ON c.FRK_REF_DATA = rd.CODE
    AND c.FSK_REF_DATA = rd.SUBCLASS
WHERE BRT.IS_CURRENT_LCP = 'Y'
AND BRT.HIERARCHY_LEVEL = 1
AND BRT.SOC_IS_ACTIVE = 'Y'
AND BRT.SOC_SUBCLASS
BETWEEN 2 AND 5
AND c.FSK_REF_DATA = 22;

SET NOCOUNT ON;
DROP TABLE IF EXISTS #TOP;
SET NOCOUNT ON;
SELECT
    ip.OBJECT_ID,
    type_of_participation_code = ISNULL(REVERSE(STUFF(REVERSE((
                                                                  SELECT RTRIM(tp.code) + ' | '
                                                                  FROM #type_of_participation tp
                                                                  WHERE ip.OBJECT_ID = tp.OBJECT_ID
                                                                  ORDER BY tp.code
                                                                  FOR XML PATH(''), TYPE
                                                              ).value('.', 'varchar(2000)')
                                                      ),
                                                      1,
                                                      2,
                                                      ''
                                                )
                                        ),
                                        'ND'
                                 )
INTO #TOP
FROM INSURED_PERIOD ip
JOIN BUSINESS b
    ON ip.FK_BUSINESS = b.OBJECT_ID
JOIN BUS_STRUCT_REP BRT
    ON ip.OBJECT_ID = BRT.FK_INS_PERIOD
JOIN BUS_CLASSIFIC bc
    ON bc.OBJECT_ID = BRT.FK_SOC_CLASSIFIC
INNER JOIN CLASSIF_REF_DATA c
    ON c.FK_CLASSIFICATION = bc.OBJECT_ID
INNER JOIN REFERENCE_DATA rd
    ON c.FRK_REF_DATA = rd.CODE
    AND c.FSK_REF_DATA = rd.SUBCLASS
WHERE BRT.IS_CURRENT_LCP = 'Y'
AND BRT.HIERARCHY_LEVEL = 1
AND BRT.SOC_IS_ACTIVE = 'Y'
AND BRT.SOC_SUBCLASS
BETWEEN 2 AND 5
AND c.FSK_REF_DATA = 22;

--SELECT * FROM #type_of_participation
--SELECT * FROM #TOP

DROP TABLE IF EXISTS #MCOB
SELECT
	DISTINCT 
	contract_object_id = inner_ip.OBJECT_ID,
	name = LTRIM(RTRIM(inner_rd.NAME)),
	code = LTRIM(RTRIM(CAST(inner_rd.CODE AS VARCHAR(15))))
INTO #MCOB
FROM INSURED_PERIOD AS inner_ip
JOIN BUSINESS AS inner_b
	ON inner_ip.FK_BUSINESS = inner_b.OBJECT_ID
JOIN BUS_STRUCT_REP AS inner_BRT
	ON inner_ip.OBJECT_ID = inner_BRT.FK_INS_PERIOD
JOIN BUS_CLASSIFIC AS inner_bc
	ON inner_bc.OBJECT_ID = inner_BRT.FK_SOC_CLASSIFIC
INNER JOIN CLASSIF_REF_DATA AS inner_c
	ON inner_c.FK_CLASSIFICATION = inner_bc.OBJECT_ID
INNER JOIN REFERENCE_DATA AS inner_rd
	ON inner_c.FRK_REF_DATA = inner_rd.CODE
	AND inner_c.FSK_REF_DATA = inner_rd.SUBCLASS
WHERE inner_BRT.IS_CURRENT_LCP = 'Y'
AND inner_BRT.HIERARCHY_LEVEL = 1
AND inner_BRT.SOC_IS_ACTIVE = 'Y'
AND inner_BRT.SOC_SUBCLASS BETWEEN 2 AND 5
AND inner_c.FSK_REF_DATA = 19 ; 
	  
UPDATE STATISTICS #MCOB;

SELECT -- TOP 1000
    contract_object_id = IP.OBJECT_ID,
    insured_period_from = Convert(date, ISNULL(BS.INSRD_PERIOD_START, '1900-01-01')),
    insured_period_to = Convert(date, ISNULL(BS.INSRD_PERIOD_END, '1900-01-01')),
    underwriting_year = ISNULL(IP.UNDERWR_YEAR, 1900),
    first_underwriting_year = '1900',                                           -- updated later 
    business_id = ISNULL(RTRIM(LTRIM(BUS.IDENTIFIER)), 'Not Defined'),
    business_title = ISNULL(LTRIM(RTRIM(BUS.TITLE)), 'Not Defined'),
    business_in_force_yn = CASE
                               WHEN ISNULL(BS.INSRD_PERIOD_END, '1900-01-01') >= GETDATE()
                               AND ISNULL(BS.INSRD_PERIOD_START, '1900-01-01') <= GETDATE()
                               AND ISNULL(RTRIM(BS.ABS_CURR_REF_NM), 'Not Defined') = 'Definite' THEN
                                   'Y'
                               ELSE
                                   'N'
                           END,
	main_class_of_business = 
		ISNULL(REVERSE(STUFF(REVERSE((select mcob.name +' | ' from #MCOB AS mcob 
		where IP.OBJECT_ID = mcob.contract_object_id 
		order by mcob.name FOR XML PATH(''), TYPE).value('.','varchar(2000)')),1,2,'')), 'Not Defined'),
	main_class_of_business_code = 
		ISNULL(REVERSE(STUFF(REVERSE((select mcob.code +' | ' from #MCOB AS mcob 
		where IP.OBJECT_ID = mcob.contract_object_id 
		order by mcob.name FOR XML PATH(''), TYPE).value('.','varchar(2000)')),1,2,'')), 'Not Defined'),                           
    level_of_business_code = ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined'),
    level_of_business = ISNULL(RTRIM(LOB.level_of_business), 'Not Defined'),
    type_of_business_code = ISNULL(RTRIM(BUS.FRK_TYPE_OF_BUS), 'Not Defined'),
    type_of_business = ISNULL(RTRIM(rdtob.NAME), 'Not Defined'),
    former_business_id = ISNULL(RTRIM(LTRIM(BUS.FORMER_IDENTIFIER)), 'Not Defined'),
    original_former_id = CASE
                             WHEN ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined') = 'IAB'
                             AND IP.ORIGINAL_FORMER_ID <> '' THEN
                                 ISNULL(LTRIM(RTRIM(IP.ORIGINAL_FORMER_ID)), 'Not Defined')
                             ELSE
                                 'Not Defined'
                         END,
    insured_period_former_id = ISNULL(LTRIM(RTRIM(IP.I_PERIOD_FORMER_ID)), 'Not Defined'),
    cease_of_accounting = CASE
                              WHEN IP.IS_CEASE_ACC = 'Y' THEN
                                  'Cease Accounting'
                              ELSE
                                  'Not Cease Accounting'
                          END,
    inception_date = Convert(date, ISNULL(BUS.INCEPTION_DATE, '1900-01-01')),
    cancellation_date = Convert(date, ISNULL(BUS.CANCELLATION_DATE, '9999-12-31')),
    cancelled_by = LTRIM(RTRIM(ISNULL(REF_CancelRelType.NAME, 'Not Defined'))), --FDM 1402
    master_treaty_group = ISNULL(RTRIM(LTRIM(MTG.IDENTIFIER)), 'Not Defined'),
    responsible_accountant_code = ISNULL(u.USER_ID, 'Not Defined'),
    responsible_accountant = CASE
                                 WHEN ran.LASTNAME IS NULL THEN
                                     'Not Defined'
                                 ELSE
                                     ran.FIRSTNAME + ' ' + ran.LASTNAME
                             END,
    is_edi_bureau_indicator = CASE
                                  WHEN IP.EDIINF_CAN_UPDATE = 'Y' THEN
                                      'Is EDI Bureau'
                                  WHEN IP.EDIINF_CAN_UPDATE = 'N' THEN
                                      'Is not EDI Bureau'
                                  WHEN IP.EMINF_MSG_IDCTR = 'Y' THEN
                                      'Is EDI Bureau'
                                  WHEN IP.EMINF_MSG_IDCTR = 'N' THEN
                                      'Is not EDI Bureau'
                                  ELSE
                                      'Not Defined'
                              END,
    agreement_basic_status_current = ISNULL(BS.ABS_CURR_REF_NM, 'Not Defined'),
    agreement_status_current = ISNULL(BS.ALCS_CURR_REF_NM, 'Not Defined'),
    agreement_substatus_current = ISNULL(BS.ALCSS_CURR_REF_NM, 'Not Defined'),
    quote_request = IIF(UDD_Business_L1_desc.NAME = '', 'Not Defined', ISNULL(UDD_Business_L1_desc.NAME, 'Not Defined')),
    signed_share = BC_SHARE.SIGNED_SHARE / 100,
    written_share = BC_SHARE.WRITTEN_SHARE / 100,
    current_share = BC_SHARE.CUR_SHARE_PCT / 100,
    estimated_signed_share = BC_SHARE.EST_SIGN_SHARE / 100,
    offered_share = BC_SHARE.OFFERED_SHARE / 100,
    main_currency_code = ISNULL(FK_SOC_CURRENCY, 'ND'),
    cease_description = ISNULL(IP.CEASE_ACC_DESCR, 'Not Defined'),
    priced_currency_code = 'ND',                                                -- ultimate_currency_code = 'ND'
    [business_group] = LTRIM(RTRIM(ISNULL(BG.NAME, 'Not Defined'))),
    to_be_commuted_code = ISNULL(RTRIM(IP.FRK_TO_BE_COMM), 'ND'),
    to_be_commuted = ISNULL(RTRIM(COMM_REF.NAME), 'Not Defined'),
    loss_adjustment_expense_cost_code = ISNULL(RTRIM(REF.CODE), 'ND'),
    loss_adjustment_expense_cost = ISNULL(RTRIM(REF.NAME), 'Not defined'),
    bureau_stamp = ISNULL(RTRIM(LTRIM(RDATA.NAME)), 'Not Defined'),
    layer_number = ISNULL(BS.LAYER_NUMBER, -1),
    new_renewed = CASE
                      WHEN LTRIM(RTRIM(ISNULL(BS.INCEPTION_DATE, ''))) = '' THEN
                          'Renewed'
                      ELSE
                          CASE
                              WHEN CONVERT(CHAR(8), BS.INSRD_PERIOD_START, 112) > CONVERT(CHAR(8), BS.INCEPTION_DATE, 112) THEN
                                  'Renewed'
                              ELSE
                                  'New'
                          END
                  END,
    aggregate_limit_100pct = ISNULL(SJ_LPC_LMT_OPFAGGL.AMOUNT, 0),
    cover_100pct = ISNULL(SJ_LPC_LMT_OPFCOV.AMOUNT, 0),
    cover_max_pct = ISNULL(SJ_LPC_LMT_OPFCOV_MAX.LIMIT_PERCENT, 0),
    cover_max_100pct = ISNULL(SJ_LPC_LMT_OPFCOV_MAX.AMOUNT, 0),
    liability_100pct = ISNULL(COALESCE(SJ_LPC_LMT_OPFLIAB.AMOUNT, 0), 0),
    retention_100pct = ISNULL(COALESCE(SJ_LPC_LMT_OPFRETENTION.AMOUNT, 0), 0),
    excess_min_100pct = ISNULL(COALESCE(SJ_LPC_LMT_OPFEXC_MIN.AMOUNT, 0), 0),
    excess_100pct = ISNULL(COALESCE(SJ_LPC_LMT_OPFEXC.AMOUNT, 0), 0),
    excess_min_pct = ISNULL(COALESCE(SJ_LPC_LMT_OPFEXC_MIN.LIMIT_PERCENT, 0), 0),
    excess_name = CASE BS.FRK_TYPE_OF_BUS
                      WHEN 'NONPROPTTY' THEN
                          CASE
                              WHEN TOPA.type_of_participation_code LIKE '%STOP%' THEN
                                  IIF(SJ_LPC_LMT_OPFEXCEST.FRK_OPTIONAL_FIELD = 'EXCESS_EST', LTRIM(RTRIM(RD1EXCEST.NAME)), '')
                              ELSE
                                  ''
                          END
                      WHEN 'PROPTTY' THEN
                          IIF(SJ_LPC_LMT_OPFRETENTION.FRK_OPTIONAL_FIELD = 'RETENTION', LTRIM(RTRIM(RD1RET.NAME)), '')
                      WHEN 'DIRECT' THEN
                          IIF(SJ_LPC_LMT_OPFRETENTION.FRK_OPTIONAL_FIELD = 'RETENTION', LTRIM(RTRIM(RD1RET.NAME)), '')
                      ELSE
                          ISNULL(LTRIM(RTRIM(RD1EXC.NAME)), '') --EXCESS
                  END,
    excess_main_curr = CASE BS.FRK_TYPE_OF_BUS
                           WHEN 'NONPROPTTY' THEN
                               CASE
                                   WHEN TOPA.type_of_participation_code LIKE '%STOP%' THEN
                                       IIF(SJ_LPC_LMT_OPFEXCEST.FRK_OPTIONAL_FIELD = 'EXCESS_EST', SJ_LPC_LMT_OPFEXCEST.AMOUNT, 0)
                                   ELSE
                                       NULL
                               END
                           WHEN 'PROPTTY' THEN
                               IIF(SJ_LPC_LMT_OPFRETENTION.FRK_OPTIONAL_FIELD = 'RETENTION', SJ_LPC_LMT_OPFRETENTION.AMOUNT, 0)
                           WHEN 'DIRECT' THEN
                               IIF(SJ_LPC_LMT_OPFRETENTION.FRK_OPTIONAL_FIELD = 'RETENTION', SJ_LPC_LMT_OPFRETENTION.AMOUNT, 0)
                           ELSE
                               ISNULL(COALESCE(SJ_LPC_LMT_OPFEXC.AMOUNT, 0), 0) --EXCESS
                       END,
    per_event_limit_if_per_risk_100pct = COALESCE(SJ_LPC_LMT_OPFPER.AMOUNT, 0),
    epi_100pct = CASE
                     WHEN ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined') IN ( 'ORP', 'OCC' ) THEN
                         -COALESCE(SJ_LPC_PRM_OPFEPI.INSURED_AMOUNT, 0)
                     ELSE
                         COALESCE(SJ_LPC_PRM_OPFEPI.INSURED_AMOUNT, 0)
                 END,
    epi_our_share = CASE
                        WHEN ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined') IN ( 'ORP', 'OCC' ) THEN
                            -COALESCE(SJ_LPC_PRM_OPFEPI.INSURED_AMOUNT, 0) * COALESCE(BC_SHARE0.CUR_SHARE_PCT_SUPI, 0) / 100
                        ELSE
                            COALESCE(SJ_LPC_PRM_OPFEPI.INSURED_AMOUNT, 0) * COALESCE(BC_SHARE0.CUR_SHARE_PCT_SUPI, 0) / 100
                    END,
    annual_aggregate_deductible_100pct = COALESCE(SJ_LPC_LMT_OPFLIA.AMOUNT, 0),
    annual_aggregate_deductible_our_share = COALESCE(SJ_LPC_LMT_OPFLIA.AMOUNT, 0)
                                            * CASE
                                                  WHEN ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined') = 'OCC' THEN
                                                      100
                                                  ELSE
                                                      COALESCE(BC_SHARE0.CUR_SHARE_PCT, 0)
                                              END / 100,
    rate_on_line = ISNULL(LPC_LIM_PREM_COND.RATE_ON_LINE_RAT, 0) / 100,
    is_manual_rate_on_line = ISNULL(LPC_LIM_PREM_COND.IS_MAN_RATE_ONL, 'ND'),

                                                                                /*Total sum insured*/
    total_sum_insured_100pct = ISNULL(SJ_LPC_LMT_TSI.AMOUNT, 0),
                                                                                -- cession limit
    cession_limit_100pct = COALESCE(SJ_LPC_LMT_OPFCES.AMOUNT, 0),
    cession_limit_our_share = COALESCE(SJ_LPC_LMT_OPFCES.AMOUNT, 0) * CASE
                                                                          WHEN ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined') = 'OCC' THEN
                                                                              100
                                                                          ELSE
                                                                              COALESCE(BC_SHARE0.CUR_SHARE_PCT, 0)
                                                                      END / 100,
                                                                                -- event limit
    event_limit_100pct = COALESCE(SJ_LPC_LMT_OPFEVE.AMOUNT, 0),
    event_limit_our_share = COALESCE(SJ_LPC_LMT_OPFEVE.AMOUNT, 0) * CASE
                                                                        WHEN ISNULL(RTRIM(LTRIM(BUS.FRK_LEVEL_OF_BUS)), 'Not Defined') = 'OCC' THEN
                                                                            100
                                                                        ELSE
                                                                            COALESCE(BC_SHARE0.CUR_SHARE_PCT, 0)
                                                                    END / 100,
    supi_basis = ISNULL(LTRIM(RTRIM(RD.NAME)), 'Not Defined'),
    supi_indicator = ISNULL(LTRIM(RTRIM(ecg.NAME)), 'Not Defined'),
    supi_amount = ISNULL(LPC_SUPI.CURRENT_AMOUNT, 0),
    supi_revised = ISNULL(LPC_RSUPI.CURRENT_AMOUNT, 0)
FROM INSURED_PERIOD IP
LEFT JOIN BUS_STRUCT_REP BS
    ON BS.FK_INS_PERIOD = IP.OBJECT_ID
    AND BS.SOC_IS_ACTIVE = 'Y'
    AND BS.HIERARCHY_LEVEL = 1
    AND BS.SOC_SUBCLASS
    BETWEEN 2 AND 5
    AND BS.IS_CURRENT_LCP = 'Y'
LEFT JOIN CANCELLATION CANCELLATION0 -- FDM 1402
    ON CANCELLATION0.OBJECT_ID = BS.FK_IP_CANC
LEFT JOIN BUSINESS_PRTNR_REL BPR_CancelRel
    ON BPR_CancelRel.FK_CANCELLATION = CANCELLATION0.OBJECT_ID
LEFT JOIN REFERENCE_DATA REF_CancelRelType
    ON REF_CancelRelType.CODE = BPR_CancelRel.FRK_RELSHIP_TYPE
    AND REF_CancelRelType.SUBCLASS = BPR_CancelRel.FSK_RELSHIP_TYPE
LEFT JOIN CLAIM_COND CC
    ON BS.FK_PC_CLAIM = CC.OBJECT_ID
LEFT JOIN REFERENCE_DATA REF
    ON CC.FRK_ADJ_EXP_TYPE = REF.CODE
    AND CC.FSK_ADJ_EXP_TYPE = REF.SUBCLASS
LEFT JOIN RESP_USER ra
    ON BS.FK_SOC = ra.FK_SOC
    AND ra.FRK_RESP_USER = 'ACCOUNTANT'
LEFT JOIN CNU_USER u
    ON ra.FK_USER = u.OBJECT_ID
LEFT JOIN CNU_USER ran
    ON ra.FK_USER = ran.OBJECT_ID
LEFT OUTER JOIN BUSINESS BUS
    ON BS.FK_BUSINESS = BUS.OBJECT_ID
LEFT JOIN REFERENCE_DATA rdtob
    ON rdtob.CODE = BUS.FRK_TYPE_OF_BUS
    AND rdtob.SUBCLASS = 46
LEFT JOIN #level_of_business AS LOB
    ON BUS.OBJECT_ID = LOB.OBJECT_ID
LEFT OUTER JOIN BUS_GROUP MTG
    ON BUS.FK_MST_TREATY_GRP = MTG.OBJECT_ID
    AND MTG.[FRK_TYPE_OF_GRP] = 'MTG'
LEFT OUTER JOIN BUS_GRP_IP_TBL BGIP
    ON IP.OBJECT_ID = BGIP.FK_INS_PERIOD
LEFT OUTER JOIN BUS_GROUP BG
    ON BGIP.FK_BUS_GRP = BG.OBJECT_ID
    AND BG.FRK_TYPE_OF_GRP = 'BG'
LEFT OUTER JOIN BC_SHARE BC_SHARE
    ON BS.FK_PC_SHARE = BC_SHARE.OBJECT_ID -- Signed & Written share   
LEFT OUTER JOIN CNU_NOTE N
    ON IP.FK_NOTE = N.OBJECT_ID
LEFT JOIN REFERENCE_DATA COMM_REF
    ON IP.FRK_TO_BE_COMM = COMM_REF.CODE
    AND COMM_REF.SUBCLASS = '286'
LEFT OUTER JOIN USER_DEF_COND CBUS
    ON BS.FK_PCLF_USERDEF = CBUS.OBJECT_ID
    AND CBUS.FRK_USR_DEF_LAYOUT = 'BUSINESS'
LEFT OUTER JOIN USER_DEF_DATA CDATA
    ON CBUS.FK_USER_DEF = CDATA.OBJECT_ID
LEFT OUTER JOIN REFERENCE_DATA RDATA
    ON CDATA.FSK_REFDATA01 = RDATA.SUBCLASS
    AND RDATA.CODE = CDATA.FRK_REFDATA01
LEFT OUTER JOIN USER_DEF_COND AS USER_DEF_COND_L1
    ON (USER_DEF_COND_L1.OBJECT_ID = BS.FK_PCLF_USERDEF)
LEFT OUTER JOIN USER_DEF_DATA AS UDD_Business_L1
    ON (UDD_Business_L1.OBJECT_ID = USER_DEF_COND_L1.FK_USER_DEF)
LEFT OUTER JOIN REFERENCE_DATA AS UDD_Business_L1_desc
    ON UDD_Business_L1_desc.CODE = UDD_Business_L1.FRK_REFDATA07 --Field Quote Request
LEFT JOIN LPC_LIM_PREM_COND AS LPC_LIM_PREM_COND
    ON LPC_LIM_PREM_COND.OBJECT_ID = BS.FK_PC_LIM_PREM
LEFT JOIN BC_SHARE BC_SHARE0
    ON BS.FK_PC_SHARE = BC_SHARE0.OBJECT_ID
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFAGGL
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFAGGL.FK_CONDITION
    AND SJ_LPC_LMT_OPFAGGL.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFAGGL.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFAGGL.FRK_OPTIONAL_FIELD = 'AGGREGATE_L'
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFCOV
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFCOV.FK_CONDITION
    AND SJ_LPC_LMT_OPFCOV.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFCOV.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFCOV.FRK_OPTIONAL_FIELD = 'COVER'
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFCOV_MAX
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFCOV_MAX.FK_CONDITION
    AND SJ_LPC_LMT_OPFCOV_MAX.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFCOV_MAX.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFCOV_MAX.FRK_OPTIONAL_FIELD = 'MAX_COVER'
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFPER
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFPER.FK_CONDITION
    AND SJ_LPC_LMT_OPFPER.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFPER.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFPER.FRK_OPTIONAL_FIELD = 'PE_COVER'
LEFT JOIN LPC_LIMIT AS SJ_LPC_LMT_OPFLIAB
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFLIAB.FK_CONDITION
    AND SJ_LPC_LMT_OPFLIAB.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFLIAB.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFLIAB.FRK_OPTIONAL_FIELD = 'LIABILITY'
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFRETENTION
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFRETENTION.FK_CONDITION
    AND SJ_LPC_LMT_OPFRETENTION.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFRETENTION.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFRETENTION.FRK_OPTIONAL_FIELD = 'RETENTION'
LEFT JOIN REFERENCE_DATA RD1RET
    ON SJ_LPC_LMT_OPFRETENTION.FSK_OPTIONAL_FIELD = RD1RET.SUBCLASS
    AND SJ_LPC_LMT_OPFRETENTION.FRK_OPTIONAL_FIELD = RD1RET.CODE
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFEXC_MIN
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFEXC_MIN.FK_CONDITION
    AND SJ_LPC_LMT_OPFEXC_MIN.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFEXC_MIN.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFEXC_MIN.FRK_OPTIONAL_FIELD = 'MIN_EXCESS'
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFEXC
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFEXC.FK_CONDITION
    AND SJ_LPC_LMT_OPFEXC.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFEXC.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFEXC.FRK_OPTIONAL_FIELD = 'EXCESS'
LEFT JOIN REFERENCE_DATA RD1EXC
    ON SJ_LPC_LMT_OPFEXC.FSK_OPTIONAL_FIELD = RD1EXC.SUBCLASS
    AND SJ_LPC_LMT_OPFEXC.FRK_OPTIONAL_FIELD = RD1EXC.CODE
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFEXCEST
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFEXCEST.FK_CONDITION
    AND SJ_LPC_LMT_OPFEXCEST.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFEXCEST.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFEXCEST.FRK_OPTIONAL_FIELD = 'EXCESS_EST'
LEFT JOIN REFERENCE_DATA RD1EXCEST
    ON SJ_LPC_LMT_OPFEXCEST.FSK_OPTIONAL_FIELD = RD1EXCEST.SUBCLASS
    AND SJ_LPC_LMT_OPFEXCEST.FRK_OPTIONAL_FIELD = RD1EXCEST.CODE
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_OPFLIA
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFLIA.FK_CONDITION
    AND SJ_LPC_LMT_OPFLIA.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFLIA.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFLIA.FRK_OPTIONAL_FIELD = 'AA_DED'
LEFT JOIN LPC_LIMIT SJ_LPC_LMT_TSI
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_TSI.FK_CONDITION
    AND SJ_LPC_LMT_TSI.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_TSI.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_TSI.FRK_OPTIONAL_FIELD = 'TSI'
LEFT JOIN LPC_LIMIT AS SJ_LPC_LMT_OPFEVE
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFEVE.FK_CONDITION
    AND SJ_LPC_LMT_OPFEVE.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFEVE.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFEVE.FRK_OPTIONAL_FIELD = 'EVENT_L'
LEFT JOIN LPC_LIMIT AS SJ_LPC_LMT_OPFCES
    ON LPC_LIM_PREM_COND.OBJECT_ID = SJ_LPC_LMT_OPFCES.FK_CONDITION
    AND SJ_LPC_LMT_OPFCES.FRK_CONDITION_PER = 'TOTAL_SUM'
    AND SJ_LPC_LMT_OPFCES.IS_ORIGINAL = 'N'
    AND SJ_LPC_LMT_OPFCES.FRK_OPTIONAL_FIELD = 'CESSION_L'
LEFT JOIN LPC_PREMIUM SJ_LPC_PRM_OPFEPI
    ON LPC_LIM_PREM_COND.FK_TOT_PREM = SJ_LPC_PRM_OPFEPI.OBJECT_ID
LEFT JOIN LPC_PREMIUM AS LPC_SUPI
    ON LPC_LIM_PREM_COND.OBJECT_ID = LPC_SUPI.FK_CONDITION
    AND LPC_SUPI.FRK_OPTIONAL_FIELD = 'SUPI'
LEFT JOIN REFERENCE_DATA AS RD
    ON LPC_LIM_PREM_COND.FRK_PREM_BASIS = RD.CODE
    AND LPC_LIM_PREM_COND.FSK_PREM_BASIS = RD.SUBCLASS
LEFT JOIN ENTRY_CODE_GROUP AS ecg
    ON LPC_LIM_PREM_COND.FK_PREM_IND = ecg.OBJECT_ID
LEFT JOIN LPC_PREMIUM LPC_RSUPI
    ON LPC_LIM_PREM_COND.OBJECT_ID = LPC_RSUPI.FK_CONDITION
    AND LPC_RSUPI.FRK_OPTIONAL_FIELD = 'REV_SUPI'
LEFT JOIN #TOP AS TOPA
    ON TOPA.OBJECT_ID = IP.OBJECT_ID
WHERE BS.HIERARCHY_LEVEL = 1
AND (
    BS.SOC_SUBCLASS
BETWEEN 2 AND 5
  OR BS.SOC_IS_LEAF = 'Z'
)
AND BS.SOC_IS_ACTIVE = 'Y'
AND BS.IS_CURRENT_LCP = 'Y';

--WHERE BS.UNDERWR_YEAR > YEAR(GETDATE()) - 10