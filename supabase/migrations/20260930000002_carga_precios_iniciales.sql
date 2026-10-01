-- =============================================================
-- Sistema de Balance — Don Chacho
-- Carga inicial de precios (lista real del Excel:
--   "LISTA PRECIOS Y RINDE CHACHO Y CABAÑA").
--
-- Fuente: sección RINDE de la hoja 'DON CHACHO' (columna PRECIO),
-- cruzada con cada corte por kgr_rinde. 38/38 cortes matcheados.
--
-- Sólo se carga precio_actual; precio_ultimo/penultimo quedan NULL
-- (la sección de rinde provee un único precio por corte).
--
-- Idempotente: es un UPDATE por corte_id; re-ejecutar re-aplica el
-- mismo valor.
-- =============================================================


update precios set precio_actual = 22990, actualizado_at = now() where corte_id = '97954dbd-7065-410e-941e-c35da2c4c2e2'; -- Carne: VACIO
update precios set precio_actual = 22950, actualizado_at = now() where corte_id = '70f9fe9e-c614-4f02-966e-8402d462f3de'; -- Carne: QUEPERI
update precios set precio_actual = 18690, actualizado_at = now() where corte_id = '1dd5bee1-4132-4c49-9ea8-207ef5138c2b'; -- Carne: MATAMBRE
update precios set precio_actual = 25950, actualizado_at = now() where corte_id = 'af7c8641-58f8-406b-a60f-d4679834bf5f'; -- Carne: VUELITO
update precios set precio_actual = 19500, actualizado_at = now() where corte_id = 'ac27dd49-bc71-46a7-8390-a819e82120d8'; -- Carne: COSTILLA ESPECIAL
update precios set precio_actual = 19180, actualizado_at = now() where corte_id = '52341bfe-edda-4069-be27-37ca38ad920e'; -- Carne: TAPA DE NALGA
update precios set precio_actual = 17590, actualizado_at = now() where corte_id = 'efcbb6a8-ca2b-49ff-b0d6-4bc5b12cc157'; -- Carne: TAPA DE ASADO
update precios set precio_actual = 11400, actualizado_at = now() where corte_id = 'b23b42ca-e318-42dc-bd66-10f1de474122'; -- Carne: ASADO OFERTA
update precios set precio_actual = 23830, actualizado_at = now() where corte_id = '3831d038-3807-41d1-8ba1-0e4fec97ab89'; -- Carne: FILET
update precios set precio_actual = 24850, actualizado_at = now() where corte_id = 'b73257aa-5d6c-45ff-83fd-06e81d88308a'; -- Carne: LOMO
update precios set precio_actual = 24850, actualizado_at = now() where corte_id = '4d7878ce-cbbb-4888-92c9-75ad34a45e3e'; -- Carne: PULPA
update precios set precio_actual = 20850, actualizado_at = now() where corte_id = '4769dcc6-5c4c-4d0a-a1bd-3566ea44022f'; -- Carne: PICANA
update precios set precio_actual = 22190, actualizado_at = now() where corte_id = 'f3f00bba-4055-4f8e-83d0-d9bdfb95f10b'; -- Carne: PECETO
update precios set precio_actual = 19750, actualizado_at = now() where corte_id = 'f7498560-329f-475e-818b-314418bca03c'; -- Carne: BOLA DE LOMO
update precios set precio_actual = 19750, actualizado_at = now() where corte_id = 'd17a2449-9529-4163-84f3-5c587aef5e71'; -- Carne: CUADRADA
update precios set precio_actual = 18950, actualizado_at = now() where corte_id = '2e3a6645-c0f9-4f73-9079-38a25b04fedd'; -- Carne: PALETA
update precios set precio_actual = 15380, actualizado_at = now() where corte_id = 'dc3be2ec-c1d5-4888-8b7d-5990e6f4dab7'; -- Carne: SOBACO
update precios set precio_actual = 15380, actualizado_at = now() where corte_id = '81260619-a159-4edf-939b-d09c0cc61edf'; -- Carne: TORTUGA
update precios set precio_actual = 10400, actualizado_at = now() where corte_id = 'c8ca8a97-4fae-415a-8e71-e809d759688c'; -- Carne: OSOBUCO
update precios set precio_actual = 2500, actualizado_at = now() where corte_id = '10bb889c-a3bd-4b80-9604-9c5e26057381'; -- Carne: PUCHERO COMUN
update precios set precio_actual = 11850, actualizado_at = now() where corte_id = '7b0e3cc0-81a4-42eb-8c43-69729e1066b6'; -- Carne: PARA CHORIZO
update precios set precio_actual = 1, actualizado_at = now() where corte_id = 'e7f8db68-cfbf-4bc8-bc94-0a25cf767bd2'; -- Carne: GRASA PARQUE
update precios set precio_actual = 1, actualizado_at = now() where corte_id = '5930ee5d-ceba-4f96-a8df-6900e0c8f8d4'; -- Carne: HUESOS
update precios set precio_actual = 9550, actualizado_at = now() where corte_id = 'be61683d-07a4-4ec9-9e33-add8ffdcef00'; -- Cerdo: COSTILLA
update precios set precio_actual = 19900, actualizado_at = now() where corte_id = '7ade2779-7081-4e7f-8a29-8e9ea5b77659'; -- Cerdo: MATAMBRE DE CERDO
update precios set precio_actual = 9975, actualizado_at = now() where corte_id = '0d7b9924-a9df-43df-80c6-1ae8211dd943'; -- Cerdo: BONDIOLA
update precios set precio_actual = 9250, actualizado_at = now() where corte_id = '8c9199de-4c74-4612-8ece-efabc87e3486'; -- Cerdo: COSTELETA DE CERDO
update precios set precio_actual = 5900, actualizado_at = now() where corte_id = 'def3d356-30b6-4d16-a7e8-54ea48ce8e5d'; -- Cerdo: PERNIL
update precios set precio_actual = 5450, actualizado_at = now() where corte_id = '37149166-4750-4070-9e0a-f305145c6683'; -- Cerdo: PALETA DE CERDO
update precios set precio_actual = 0, actualizado_at = now() where corte_id = '5e9e3e2b-e744-4d45-89ae-176524aa3a19'; -- Cerdo: PARA CHORIZO
update precios set precio_actual = 0, actualizado_at = now() where corte_id = 'f381309c-53be-4785-90d3-b1db319bd351'; -- Cerdo: CUERO Y CABEZA
update precios set precio_actual = 0, actualizado_at = now() where corte_id = '3ba811ad-c3cc-481b-8bc6-d40973192c5e'; -- Cerdo: GRASA
update precios set precio_actual = 0, actualizado_at = now() where corte_id = '45780407-15eb-4813-939c-55274713cc17'; -- Cerdo: PATITAS Y DESPERDICIOS
update precios set precio_actual = 10850, actualizado_at = now() where corte_id = '1e51c7a8-da1e-4aea-bbd9-6d9a91646157'; -- Pollo: PECHUGAS
update precios set precio_actual = 6100, actualizado_at = now() where corte_id = '4c839efe-fa27-41d5-a9ec-ec14d242a661'; -- Pollo: PATA MUSLO
update precios set precio_actual = 4900, actualizado_at = now() where corte_id = '9a09f16c-04bb-4988-b89b-1d276686f2cf'; -- Pollo: ALITAS
update precios set precio_actual = 1800, actualizado_at = now() where corte_id = 'b94e5437-6c3e-484e-b812-b1df84be87c0'; -- Pollo: MENUDO
update precios set precio_actual = 500, actualizado_at = now() where corte_id = '88be5129-b812-4614-9ec9-2da9bb9a886e'; -- Pollo: PUCHERO
