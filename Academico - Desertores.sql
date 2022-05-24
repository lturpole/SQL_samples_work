
/******************************************************
Alumnos desertores (que no volvieron este mes) en un intervalo de tiempo X hasta Y
	X:	@FechaInicioCicloDesde
	Y:	@FechaInicioCicloHasta
******************************************************/
--Use CCPNA;
IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_periodo', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_periodo;
  
IF OBJECT_ID('tempdb.dbo.#tmp_desertores', 'U') IS NOT NULL
  DROP TABLE #tmp_desertores;

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
SET @FechaInicioCicloDesde	= '2017-08-01';
SET @FechaInicioCicloHasta	= '2021-04-20';--(OBVIAMENTE NO SE CUENTA ESTE MES)--CONVERT(varchar,getdate(),23)--;
SET @Mesestranscurridos		= 0; --igual o mayor //meses transcurridos desde su matricula anterior (usar 0 para todas sus matriculas)
--SET @Aprobado				= 'A'; --'A' o 'D' para filtrar aprobados y desaprobados



/*
	1.	TODOS LOS MATRICULADOS EN EL INTERVALO DE FECHAS ESTABLECIDO 
*/
select distinct(mat.clte_codcli)
INTO #tmp_matriculados_periodo
from		matriculas	mat
INNER JOIN	CICLOS			CIC	ON cic.CICL_CodCiclo	= mat.CICL_CodCiclo		and cic.[SUCR_CodSuc]	= @Sede
inner join	cursosofrecidos	COF on cof.CROF_CodCurso	= mat.CROF_CodCurso		and cof.SUCR_CodSuc		= @Sede
LEFT JOIN	(
				--ALUMNOS EN CURSOS FINALES
				SELECT distinct(mat.clte_codcli) 
				FROM MATRICULAS MAT
				INNER JOIN	CICLOS			CIC	ON cic.CICL_CodCiclo	= mat.CICL_CodCiclo		and cic.[SUCR_CodSuc]	= @Sede
				inner join	cursosofrecidos	COF on cof.CROF_CodCurso	= mat.CROF_CodCurso		and cof.SUCR_CodSuc		= @Sede
				WHERE 
					(dateadd(day,10,cic.CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
					and mat.SUCR_CodSuc	= @Sede		
					and mat.matr_estado = 'C'
					AND COF.CROF_Nombre IN ('B2-06','B2_06','B2-6','B2_6',
											'B2-04-IN','B2_04_IN','B2-4-IN','B2_4_IN')
			) B ON mat.clte_codcli = B.clte_codcli
where 
	(dateadd(day,10,cic.CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
	and mat.SUCR_CodSuc	= @Sede		
	and mat.matr_estado = 'C'
	AND b.clte_codcli IS NULL
	
--select  * from #tmp_matriculados_periodo


/*
	2.	DESERTORES
*/
SELECT 
	b.CLTE_CODCLI
INTO #tmp_desertores
FROM 
	(
		--MATRICULADOS DE ESTE MES en adelante
		SELECT 
			MAT.CLTE_CODCLI
		FROM		MATRICULAS	MAT
		INNER JOIN	CICLOS		CIC	ON cic.CICL_CodCiclo	= mat.CICL_CodCiclo		and cic.[SUCR_CodSuc] = @Sede
		WHERE
			YEAR(dateadd(day,10,cic.CICL_FecIniClass))	>= YEAR(GETDATE())	AND
			MONTH(dateadd(day,10,cic.CICL_FecIniClass))	>= MONTH(GETDATE())	AND
			mat.SUCR_CodSuc	= @Sede	AND
			mat.matr_estado = 'C'
		--ORDER BY CICL_Descripcion
	)	A
RIGHT JOIN #tmp_matriculados_periodo B	ON A.CLTE_CODCLI = B.CLTE_CODCLI
WHERE A.CLTE_CODCLI IS NULL





/*
	3.	historial de matriculas de alumnos dentro de la lista DESERTORES
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
	mat.CLTE_CodCli in(select CLTE_CodCli from		#tmp_desertores	)
	and mat.SUCR_CodSuc	= @Sede
	and mat.matr_estado = 'C'
order by 
mat.CLTE_CodCli
,MATR_NumMat
--select * from #tmp_matriculados_historial_validos order by CLTE_CodCli


/*
	4.	reporte: resumen por meses: Alumnos nuevos en un intervalo de tiempo @FechaInicioCicloDesde	hasta @FechaInicioCicloHasta
	/*selecciona primera matricula de cada alumno de la lista*/
*/
select
    Año
    ,Mes
    ,count(*) as Desertores
from #tmp_matriculados_historial_validos x1
where
    (
    select count(*)
    from #tmp_matriculados_historial_validos x2
    where x2.clte_codcli = x1.clte_codcli
    and x2.CICL_FecIniClass >= x1.CICL_FecIniClass
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
	12	*	 (YEAR((cast(year(dateadd(day,10,getdate())) as varchar(4))			+ '-' + right ('00'+ltrim(str( month(dateadd(day,10,getdate())) )),2 )				+ '-' + '01')) 
			- YEAR((cast(year(dateadd(day,10,x1.CICL_FecIniClass)) as varchar(4))	+ '-' + right ('00'+ltrim(str( month(dateadd(day,10,x1.CICL_FecIniClass)) )),2 )	+ '-' + '01'))) 
			+ (MONTH((cast(year(getdate()) as varchar(4))			+ '-' + right ('00'+ltrim(str( month(getdate()))),2 )				+ '-' + '01')) 
           - MONTH((cast(year(dateadd(day,10,x1.CICL_FecIniClass)) as varchar(4))	+ '-' + right ('00'+ltrim(str( month(dateadd(day,10,x1.CICL_FecIniClass)) )),2 )	+ '-' + '01'))) AS Meses_Sin_Matricularse
           /*
    (cast(year(dateadd(day,10,getdate())) as varchar(4))			+ '-' + right ('00'+ltrim(str( month(dateadd(day,10,getdate())) )),2 )				+ '-' + '01')
    (cast(year(dateadd(day,10,cic.CICL_FecIniClass)) as varchar(4))	+ '-' + right ('00'+ltrim(str( month(dateadd(day,10,cic.CICL_FecIniClass)) )),2 )	+ '-' + '01')
    */
    ,*
from #tmp_matriculados_historial_validos x1
where
    (
    select count(*)
    from #tmp_matriculados_historial_validos x2
    where x2.clte_codcli = x1.clte_codcli
    and x2.CICL_FecIniClass >= x1.CICL_FecIniClass
    ) <= 1
order by
--x1.clte_codcli
año
,mes
,TIPO_Desc12
,TIPO_Desc11
,CURS_Descripcion
,CROF_Nombre
,CLTE_Apellido,CLTE_Nombre
;




/*
	X.	Comprobacion: debe dar vacio
*/
/*
select * 
from matriculas			mat
INNER JOIN CICLOS		CIC	ON cic.CICL_CodCiclo	= mat.CICL_CodCiclo		and cic.[SUCR_CodSuc] = @Sede
where 
	clte_codcli in 
	(
		select
			distinct(x1.clte_codcli)
		from #tmp_matriculados_historial_validos x1
	)

	and dateadd(day,10,cic.CICL_FecIniClass)< @FechaInicioCicloDesde 
	and mat.SUCR_CodSuc	= @Sede
	and mat.matr_estado = 'C'
order by clte_codcli 
*/