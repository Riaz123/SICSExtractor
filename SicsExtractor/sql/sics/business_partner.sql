SELECT DISTINCT
       pcat.FRK_CATEGORY AS category,
       o.FK_ORGANISATION AS business_partner_object_id,
       p.CURR_NAME name,
       p.LOCATION location,
       p.IDENTIFIER AS identifier,
       p.FRK_RSN_FOR_ALERT AS alert_reason,
       c.NAME AS country,
       CASE
           WHEN p.IS_BASE_COMPANY = 'Y' THEN
               1
           WHEN p.IS_BASE_COMPANY != 'Y' THEN
               0
       END AS is_base_company,
       CASE
           WHEN p.IS_ACTIVE = 'Y' THEN
               1
           WHEN p.IS_ACTIVE != 'Y' THEN
               0
       END AS is_active,
       CASE
           WHEN p.IS_INSURED = 'Y' THEN
               1
           WHEN p.IS_INSURED != 'Y' THEN
               0
       END AS is_third_party,
       CASE
           WHEN p.IS_BUS_PARTNER = 'Y' THEN
               1
           WHEN p.IS_BUS_PARTNER != 'Y' THEN
               0
       END AS is_business_partner,
       CASE
           WHEN p.IS_ALERT = 'Y' THEN
               1
           WHEN p.IS_ALERT != 'Y' THEN
               0
       END AS is_alert,
       p.FRK_STATUS status
FROM DB_NAME.PARTY p
    JOIN DB_NAME.ORGANISATION_NAME o
        ON p.OBJECT_ID = o.FK_ORGANISATION
           -- 3 means current name of the company
           AND o.SUBCLASS = 3
    JOIN DB_NAME.LEGAL_AREA c
        ON p.FK_HOME_COUNTRY = c.OBJECT_ID
    JOIN BUS_PARTNER_CAT pcat
        ON p.OBJECT_ID = pcat.FK_PARTNER
-- 4 means business partner
WHERE p.SUBCLASS = 4
      AND p.OBJECT_ID NOT IN
          (
              SELECT FK_PARTNER FROM BUS_PARTNER_CAT WHERE FRK_CATEGORY = 'LAWYER'
          );
