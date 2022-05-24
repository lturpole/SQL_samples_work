
DECLARE @codSuc char(2)
SET @codSuc ='01'
--=================================================================
-- se obtienen los ciclos del mes y año indicados
--=================================================================
--drop table #tmpCodCiclos
IF OBJECT_ID('tempdb.dbo.#tmpCodCiclos', 'U') IS NOT NULL
  DROP TABLE #tmpCodCiclos;

SELECT cicl_codciclo 
into #tmpCodCiclos
FROM ciclos 
WHERE 
	year(DATEADD(DAY,10,CICL_FecIniClass)) = 2021
	and month(DATEADD(DAY,10,CICL_FecIniClass)) = 08
	and sucr_codsuc = @codSuc
ORDER BY cicl_codciclo desc

--=================================================================
-- se obtienen las matriculas con boleta o factura de los ciclos hallados previamente 
--=================================================================
SELECT
	su.SUCR_Descripcion1 'sede'
	,ci.cicl_codciclo 'codCiclo'
	,ci.CICL_Descripcion 'ciclo'
	,cp.comp_numcomppago 'numcomppago'
	,ltrim(rtrim(cp.comp_seriefactelec)) + '-' + ltrim(rtrim(cp.comp_numsunat)) 'S-N'
	,cp.comp_estado 'estado'
	,cp.comp_monto 'monto'
	,cp.COMP_ValorVta 'valor vta'
	,cp.COMP_Impuesto 'impuesto'
	,cp.COMP_Descuento 'dscto'
	,cp.comp_fecemi 'fecha emision'
FROM matriculas m
JOIN ciclos ci ON ci.cicl_codciclo = m.cicl_codciclo AND ci.sucr_codsuc = m.sucr_codsuc
JOIN #tmpCodCiclos tcc ON tcc.cicl_codciclo = ci.cicl_codciclo
JOIN detcomppago dcp ON dcp.matr_nummat = m.matr_nummat AND dcp.sucr_codsuc = m.sucr_codsuc
JOIN comppago cp ON cp.comp_numcomppago = dcp.dcom_numcomppago AND cp.sucr_codsuc = m.sucr_codsuc
JOIN sucursales su ON su.SUCR_CodSuc = m.sucr_codsuc
----JOIN tipos tiTDO ON tiTDO.tipo_codtabla = cp.TIPO_TCodTipoComp AND tiTDO.tipo_codtipo = cp.TIPO_CCodTipoComp
----JOIN tipos tiFPG ON tiFPG.tipo_codtabla = cp.TIPO_TCodFPG AND tiFPG.tipo_codtipo = cp.TIPO_CCodFPG
WHERE
	m.sucr_codsuc = @codSuc
	AND m.matr_estado = 'C'
	AND cp.TIPO_TCodTipoComp = 'TDO'
	AND cp.TIPO_CCodTipoComp IN ('003','001')
	----,tiTDO.tipo_Desc1
	----,tiFPG.tipo_Desc1
ORDER BY 
	ciclo
	,ltrim(rtrim(cp.comp_seriefactelec)) + '-' + ltrim(rtrim(cp.comp_numsunat))





