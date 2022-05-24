/*
Alumnos nuevos en un intervalo de tiempo X hasta Y
	X:	@FechaInicioCicloDesde
	Y:	@FechaInicioCicloHasta
*/

--Use CCPNA;
IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_periodo', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_periodo;

IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_historial', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_historial;
  
IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_historial_validos', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_historial_validos;

DECLARE @Sede					varchar(2);
DECLARE @FechaInicioCicloDesde	varchar(10);
DECLARE @FechaInicioCicloHasta	varchar(10);
DECLARE @Mesestranscurridos		varchar(10);
--DECLARE @Aprobado				varchar(1);



SET @Sede					= '01';
SET @FechaInicioCicloDesde	= '2019-02-01';
SET @FechaInicioCicloHasta	= '2021-05-20';
SET @Mesestranscurridos		= 0; --igual o mayor //meses transcurridos desde su matricula anterior (usar 0 para todas sus matriculas)
--SET @Aprobado				= 'A'; --'A' o 'D' para filtrar aprobados y desaprobados


/*
	1.	TODOS LOS MATRICULADOS EN EL INTERVALO DE FECHAS ESTABLECIDO
*/
select distinct(mat.clte_codcli)
INTO #tmp_matriculados_periodo
from		matriculas	mat
INNER JOIN CICLOS		CIC	ON cic.CICL_CodCiclo	= mat.CICL_CodCiclo		and cic.[SUCR_CodSuc] = @Sede
where 
	(dateadd(day,10,cic.CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
	and mat.SUCR_CodSuc	= @Sede		
	and mat.matr_estado = 'C'
--select  * from #tmp_matriculados_periodo




/*
	2.	Historial de matriculas de los que se matricularon en el intervalo
		junto con un flag que determina si la matricula es antes del intervalo fijado
*/
select 
	clte_codcli
	,CASE
		WHEN (cast(year(dateadd(day,10,cic.CICL_FecIniClass)) as varchar(4)) 
			+ '-' + right ('00'+ltrim(str( month(cic.CICL_FecIniClass) )),2 )
			+ '-' + '01') < @FechaInicioCicloDesde THEN 'si'
		/*WHEN (cast(year(dateadd(day,10,cic.CICL_FecIniClass)) as varchar(4)) 
			+ '-' + right ('00'+ltrim(str( month(cic.CICL_FecIniClass) )),2 )
			+ '-' + '01') >= @FechaInicioCicloDesde THEN 'no'*/
		ELSE 'no'
	 END 'antiguo'
into #tmp_matriculados_historial
from matriculas	MAT
INNER JOIN CICLOS		CIC	ON cic.CICL_CodCiclo	= mat.CICL_CodCiclo		and cic.[SUCR_CodSuc] = @Sede
where 
	mat.clte_codcli IN (SELECT clte_codcli FROM #tmp_matriculados_periodo)
	and mat.SUCR_CodSuc	= @Sede		
	and mat.matr_estado = 'C'
order by mat.clte_codcli,cic.CICL_FecIniClass
--select * from #tmp_matriculados_historial order by clte_codcli--,CICL_FecIniClass




/*
	3.	historial de matriculas de alumnos dentro de la lista
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
	,TIP.TIPO_Desc2			as TIPO_Desc22
	,TIP.TIPO_DescC			as TIPO_DescC2
	,convert(varchar, cic.CICL_FecIniClass, 23)	as CICL_FecIniClass
	,convert(varchar, cic.CICL_FecFin, 23)		as CICL_FecFin
	,cic.CICL_Descripcion
	
	,TIP.TIPO_Desc1			AS Fase
	,TI2.TIPO_Desc1
	,TI2.TIPO_Desc2
	,TI2.TIPO_DescC
	
	--CARRERA
	,car.CARR_CodCarr
	,car.CARR_Nombre		AS Carrera		--SELECT * FROM CARRERAS
	
	--trabajadores
	,tra.TRAB_Cod
	,tra.TRAB_Nombre1
	,tra.TRAB_Apellido1


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

where
	mat.CLTE_CodCli in(
		select A.CLTE_CodCli 
		from		#tmp_matriculados_periodo	A
		left join	(select distinct(CLTE_CodCli) as CLTE_CodCli from #tmp_matriculados_historial where antiguo = 'si')	B
		on A.CLTE_CodCli = B.CLTE_CodCli
		where B.CLTE_CodCli is NULL
	)
	and mat.SUCR_CodSuc	= @Sede
	and mat.matr_estado = 'C'
order by 
mat.CLTE_CodCli
,MATR_NumMat
--select * from #tmp_matriculados_historial_validos


/*
	4.	reporte: resumen por meses: Alumnos nuevos en un intervalo de tiempo @FechaInicioCicloDesde	hasta @FechaInicioCicloHasta
	/*selecciona primera matricula de cada alumno de la lista*/
*/
select
    Año
    ,Mes
    ,count(*) as cantidad
from #tmp_matriculados_historial_validos x1
where
    (
    select count(*)
    from #tmp_matriculados_historial_validos x2
    where x2.clte_codcli = x1.clte_codcli
    and x2.CICL_FecIniClass <= x1.CICL_FecIniClass
    ) <= 1
group by
	Año
    ,Mes     
order by 
	Año
    ,Mes
    
    
    
/*
	5.	reporte: detalle: Alumnos nuevos en un intervalo de tiempo @FechaInicioCicloDesde	hasta @FechaInicioCicloHasta	
*/
select
    *
from #tmp_matriculados_historial_validos x1
where
    (
    select count(*)
    from #tmp_matriculados_historial_validos x2
    where x2.clte_codcli = x1.clte_codcli
    and x2.CICL_FecIniClass <= x1.CICL_FecIniClass
    ) <= 1
order by
año
,mes
,TIPO_Desc12
,TIPO_Desc11
,CURS_Descripcion
,CROF_Nombre
,CLTE_Apellido,CLTE_Nombre
;


