
/*
Alumnos que regresan en N o mas mese en un intervalo de tiempo X hasta Y
	X:	@FechaInicioCicloDesde
	Y:	@FechaInicioCicloHasta
*/
--Use CCPNA;
IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_periodo', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_periodo;
  
IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_historial_validos', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_historial_validos;

IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_historial_completo', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_historial_completo;
  

DECLARE @Sede					varchar(2);
DECLARE @FechaInicioCicloDesde	varchar(10);
DECLARE @FechaInicioCicloHasta	varchar(10);
DECLARE @Mesestranscurridos		varchar(10);
--DECLARE @Aprobado				varchar(1);



SET @Sede						= '01';
SET @FechaInicioCicloDesde		= '2020-01-01';--'${VAR_FechaInicioCicloDesde}';
--SET @FechaInicioCicloDesde		= '${VAR_FechaInicioCicloDesde}';
--SET @FechaInicioCicloHasta	= '${VAR_FechaInicioCicloHasta}';
SET @FechaInicioCicloHasta		= convert(varchar, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 14),23);	--el dia 15 DE ESTE mes
SET @Mesestranscurridos			= 6; --igual o mayor //meses transcurridos desde su matricula anterior (usar 0 para todas sus matriculas)
--SET @Aprobado					= 'A'; --'A' o 'D' para filtrar aprobados y desaprobados





/*
	1.	TODOS LOS MATRICULADOS EN EL INTERVALO DE FECHAS ESTABLECIDO 
*/
select distinct(mat.clte_codcli)
INTO #tmp_matriculados_periodo
from		matriculas	mat
INNER JOIN	CICLOS			CIC	ON cic.CICL_CodCiclo	= mat.CICL_CodCiclo		and cic.[SUCR_CodSuc]	= @Sede
inner join	cursosofrecidos	COF on cof.CROF_CodCurso	= mat.CROF_CodCurso		and cof.SUCR_CodSuc		= @Sede
where 
	(dateadd(day,10,cic.CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
	and mat.SUCR_CodSuc	= @Sede		
	and mat.matr_estado = 'C'
--select  * from #tmp_matriculados_periodo










/*
	2.	historial de matriculas de alumnos dentro de la lista #tmp_matriculados_periodo
*/
SELECT
	year(dateadd(day,10,cic.CICL_FecIniClass))		as Año
    ,month(dateadd(day,10,cic.CICL_FecIniClass))	as Mes
	--CLIENTE
	,mat.SUCR_CodSuc				as sede
	,mat.CLTE_CodCli
	,cli.CLTE_Apellido
	,cli.CLTE_Nombre
	
	--datos personales
	,cli.CLTE_DocIden
	,cli.CLTE_EMail
	,cli.CLTE_Tel1
	,cli.[CLTE_Tel2]
	,cli.[CLTE_Celular]
	,cli.[CLTE_TelOfPadre]
	,cli.[CLTE_TelCelPadre]
	,cli.[CLTE_TelOfMadre]
	,cli.[CLTE_TelCelMadre]
	,cli.[CLTE_TelContacEmerg]
	,cli.[CLTE_CelContacEmerg]
	
	
	--MATRICULA
	,cof.CROF_CodCurso
	,cof.CROF_Nombre
	
	--curso
	,CUR.CURS_Descripcion
	,TI2.TIPO_Desc1		as TIPO_Desc11
	
	--salon
	,hor.HORA_Inicio		as Hora
	
	,mat.MATR_NotaFinal		as nota
	,mat.MATR_Aprobado		as Aprobado
	
	--CICLO
	,mat.CICL_CodCiclo
	,TIP.TIPO_Desc1			as TIPO_Desc12
	--,TIP.TIPO_Desc2			as TIPO_Desc22
	--,TIP.TIPO_DescC			as TIPO_DescC2
	,convert(varchar, cic.CICL_FecIniClass, 23)	as CICL_FecIniClass
	,convert(varchar, cic.CICL_FecFin, 23)		as CICL_FecFin
	,cic.CICL_Descripcion	--as	'Ultimo curso llevado'
	
	,TIP.TIPO_Desc1			AS Fase
	,TI2.TIPO_Desc1
	--,TI2.TIPO_Desc2
	--,TI2.TIPO_DescC
	
	--CARRERA
	--,car.CARR_CodCarr
	,car.CARR_Nombre		AS Carrera		--SELECT * FROM CARRERAS
	
	--trabajadores
	,tra.TRAB_Cod
	,tra.TRAB_Nombre1
	,tra.TRAB_Apellido1
	
	,DCP.DCOM_ValorVtaReal
	,MAT.MATR_NumMat


into #tmp_matriculados_historial_validos			
FROM Matriculas	mat
	inner join clientes			CLI on cli.CLTE_CodCli		= mat.CLTE_CodCli			and cli.SUCR_CodSuc		= @Sede
	inner join ciclos			CIC on cic.cicl_codciclo	= mat.cicl_codciclo			and cic.SUCR_CodSuc		= @Sede		--and CICL_Estado = 'C'
	inner join cursosofrecidos	COF on cof.CROF_CodCurso	= mat.CROF_CodCurso			and cof.SUCR_CodSuc		= @Sede
	inner join tipos			TIP on tip.tipo_codtipo		= cic.TIPO_CCodTipoCiclo	and TIP.TIPO_CODTABLA	= cic.TIPO_TCodTipoCiclo
	inner join CURSOS			CUR ON CUR.CURS_CodCurso	= cof.CURS_CodCurso			and CUR.SUCR_CodSuc		= @Sede
	inner join salones			SAL ON SAL.salo_codsalon	= cof.salo_codsalon			and SAL.SUCR_CodSuc		= @Sede 
	inner join Horarios			HOR ON HOR.HORA_CodHora		= cof.HORA_CodHora			and HOR.SUCR_CodSuc		= @Sede
	left join Trabajadores		TRA	ON TRA.TRAB_COD			= cof.Trab_cod				and TRA.SUCR_CodSuc		= @Sede
	inner join carreras			CAR on car.CARR_CodCarr		= cur.CARR_CodCarr			and CAR.SUCR_CodSuc		= @Sede
	inner join tipos			TI2 ON TI2.TIPO_CODTIPO		= cur.TIPO_CodFase			and TI2.TIPO_CODTABLA	= cur.TIPO_TabFase
	
	left	join detcomppago		DCP on DCP.MATR_NumMat		= mat.MATR_NumMat			and DCP.SUCR_CodSuc		= @Sede		and TIPO_CCodConcep = '001'
	left	join comppago			CPG ON CPG.CLTE_CodCli		= mat.CLTE_CodCli			and CPG.COMP_NumCompPago = DCP.DCOM_NumCompPago	and cpg.SUCR_CodSuc		= @Sede 	and CPG.COMP_Estado = 'P'


where
	mat.CLTE_CodCli	in (select CLTE_CodCli from		#tmp_matriculados_periodo)	and 
	mat.SUCR_CodSuc	= @Sede
	and mat.matr_estado = 'C'
order by 
mat.CLTE_CodCli
,mat.MATR_NumMat
--select * from #tmp_matriculados_historial_validos order by CLTE_CodCli





/******************************************************
3. aniado al historial completo los meses transcurridos desde su matricula anterior
******************************************************/
	--primera matricula
	SELECT 0 as Meses_transucrridos_desde_matricula_anterior, * 
	into #tmp_matriculados_historial_completo
	FROM #tmp_matriculados_historial_validos t1
	WHERE CICL_FecIniClass = (select MIN(CICL_FecIniClass)	from #tmp_matriculados_historial_validos t2 where t2.CLTE_CodCli = t1.CLTE_CodCli)
	
	--resto de matriculas
	insert into #tmp_matriculados_historial_completo
	select 
		DATEDIFF(month, (
			SELECT TOP 1 CICL_FecIniClass FROM #tmp_matriculados_historial_validos T2 WHERE T2.CICL_FecIniClass<T1.CICL_FecIniClass and t1.CLTE_CodCli = t2.CLTE_CodCli
			ORDER BY CICL_FecIniClass desc
			), t1.CICL_FecIniClass) AS Meses_transucrridos_desde_matricula_anterior
		,*
	from #tmp_matriculados_historial_validos T1
	where DATEDIFF(month, (
			SELECT TOP 1 CICL_FecIniClass FROM #tmp_matriculados_historial_validos T2 WHERE T2.CICL_FecIniClass<T1.CICL_FecIniClass and t1.CLTE_CodCli = t2.CLTE_CodCli
			ORDER BY CICL_FecIniClass desc
			), t1.CICL_FecIniClass) >= 0





/******************************************************
4.	reporte: alumnos matriculados en rango especificado que volvieron despes de N meses
		N: @Mesestranscurridos
******************************************************/
select
    Año
    ,Mes
    ,count(*) as #Retornaron
    ,sum(DCOM_ValorVtaReal) as Monto
from #tmp_matriculados_historial_completo x1
where
    (dateadd(day,10,CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
	and Meses_transucrridos_desde_matricula_anterior >= @Mesestranscurridos
group by
	Año
    ,Mes     
order by 
	Año
    ,Mes
    
    
    
    


/******************************************************
5. reporte: alumnos matriculados en rango especificado que volvieron despes de N meses
		N: @Mesestranscurridos
******************************************************/

select * from #tmp_matriculados_historial_completo
where 
(dateadd(day,10,CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
and Meses_transucrridos_desde_matricula_anterior >= @Mesestranscurridos
order by 
--clte_codcli
año
,mes
,TIPO_Desc12
,TIPO_Desc11
,CURS_Descripcion
,CROF_Nombre
,CLTE_Apellido,CLTE_Nombre
;




---FIN---