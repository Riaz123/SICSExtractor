-- Connects a business partner to a contract
SELECT RTRIM(B.FK_INS_PERIOD) contract_object_id,
       RTRIM(REF_Data.NAME) business_partner_role,
       PTY_Partner.OBJECT_ID business_partner_object_id
FROM PARTY PTY_Partner
    INNER JOIN BUSINESS_PRTNR_REL BP_REL
        ON PTY_Partner.OBJECT_ID = BP_REL.FK_BUS_PARTNER
    INNER JOIN REFERENCE_DATA REF_Data
        ON BP_REL.FRK_RELSHIP_TYPE = REF_Data.CODE
           AND BP_REL.FSK_RELSHIP_TYPE = REF_Data.SUBCLASS
    INNER JOIN BUS_STRUCT_REP B
        ON BP_REL.FK_INS_PERIOD = B.FK_INS_PERIOD
WHERE B.SOC_IS_ACTIVE = 'Y'
      AND B.HIERARCHY_LEVEL = 1
      AND B.SOC_SUBCLASS
      BETWEEN 2 AND 5
      AND B.IS_CURRENT_LCP = 'Y';
