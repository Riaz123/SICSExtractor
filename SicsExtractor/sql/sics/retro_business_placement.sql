SELECT
    DISTINCT
    PA.FK_INS_PERIOD                                 AS pa_contract_object_id,
    PA.IDENTIFIER                                    AS pa_business_id,
    CAST(PA.INSRD_PERIOD_START AS DATE)              AS pa_insured_period_from,
    PA.UNDERWR_YEAR                                  AS pa_underwriting_year,
    COALESCE(BC_SHARE_PlmDef.CUR_SHARE_PCT / 100, 0) AS pa_def_placed_pct,
    --    BC_SHARE_PlmDef.FRK_EXPRESSED_AS			AS [Share expressed as],
    PA.TITLE                                         AS pa_title,
    OP.TITLE                                         AS op_title,
    OP.FK_INS_PERIOD                                 AS op_contract_object_id,
    OP.IDENTIFIER                                    AS op_business_id,
    OP.UNDERWR_YEAR                                  AS op_underwriting_year,
    CAST(OP.INSRD_PERIOD_START AS DATE)              AS op_insured_period_from,
    ISNULL(BC_SHARE_Plmnts.SIGNED_SHARE / 100, 0)    AS op_current_share,
    RTRIM(OP.ALCS_CURR_REF_NM)                       AS op_lifecycle_status
FROM BUS_STRUCT_REP      AS PA
LEFT JOIN BUS_STRUCT_REP AS OP
    ON OP.FK_IP_OCC = PA.FK_INS_PERIOD
    AND OP.IS_CURRENT_LCP = 'Y'
    AND OP.HIERARCHY_LEVEL = 1
LEFT JOIN BC_SHARE       AS BC_SHARE_Plmnts
    ON BC_SHARE_Plmnts.OBJECT_ID = OP.FK_PC_SHARE
LEFT JOIN BUS_STRUCT_REP AS OPDef
    ON OPDef.OBJECT_ID = OP.OBJECT_ID
    AND OPDef.IS_CURRENT_LCP = 'Y'
    AND OPDef.HIERARCHY_LEVEL = 1
    AND OPDef.FRK_BASICSTAT_CURR = 'DEF'
LEFT JOIN BC_SHARE       AS BC_SHARE_PlmDef
    ON BC_SHARE_PlmDef.OBJECT_ID = OPDef.FK_PC_SHARE
WHERE OP.FRK_LEVEL_OF_BUS = 'ORP'
--AND YEAR(CAST(PA.INSRD_PERIOD_START AS DATE)) >= 2020
--AND PA.IDENTIFIER IN ( 'OP531', 'OPPR623' )
--AND PA.INSRD_PERIOD_START = '2021-01-01'
--AND isnull(BC_SHARE_Plmnts.SIGNED_SHARE,0) <> coalesce(BC_SHARE_PlmDef.CUR_SHARE_PCT, 0)

