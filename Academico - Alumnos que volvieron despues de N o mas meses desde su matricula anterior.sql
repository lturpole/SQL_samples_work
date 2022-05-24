/******************************************************
Alumnos que volvieron despues de N o mas meses desde su matricula anterior
	N = @Mesestranscurridos
******************************************************/
Use CCPNA;
IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_periodo', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_periodo;

IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_historial', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_historial;
  
IF OBJECT_ID('tempdb.dbo.#tmp_matriculados_historial_completo', 'U') IS NOT NULL
  DROP TABLE #tmp_matriculados_historial_completo;

IF OBJECT_ID('tempdb.dbo.#HISTORIAL_primeras_mat_x_alumno', 'U') IS NOT NULL
  DROP TABLE #HISTORIAL_primeras_mat_x_alumno;

DECLARE @Sede					varchar(2);
DECLARE @FechaInicioCicloDesde	varchar(10);
DECLARE @FechaInicioCicloHasta	varchar(10);
DECLARE @Mesestranscurridos		varchar(10);
DECLARE @Aprobado				varchar(1);



SET @Sede					= '01';
SET @FechaInicioCicloDesde	= '2021/02/01';
SET @FechaInicioCicloHasta	= '2021/05/20';
SET @Mesestranscurridos		= 6; --igual o mayor //meses transcurridos desde su matricula anterior (usar 0 para todas sus matriculas)
SET @Aprobado				= 'A'; --'A' o 'D' para filtrar aprobados y desaprobados

/*******************************************************************************
1. Alumnos matrioculados entre @FechaInicioCicloDesde hasta @FechaInicioCicloHasta  
*******************************************************************************/
select 
	distinct mat.clte_codcli
	into #tmp_matriculados_periodo
from matriculas mat 
	inner join clientes				cli		on mat.clte_codcli = cli.clte_codcli and mat.[SUCR_CodSuc] = @Sede and cli.[SUCR_CodSuc] = @Sede
	INNER JOIN CICLOS				CIC		ON	cic.CICL_CodCiclo	= mat.CICL_CodCiclo
where 
(dateadd(day,10,cic.CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
and mat.MATR_Estado		= 'C'
--and MATR_Aprobado		= @Aprobado
order by mat.clte_codcli

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        --select * from #tmp_matriculados_periodo



/*******************************************************************************
2. Todas las matriculas de los alumnos en la lista anterior
*******************************************************************************/
select 
			mat.[SUCR_CodSuc]
			,year(dateadd(day,10,cic.CICL_FecIniClass)) as Anio
			,month(dateadd(day,10,cic.CICL_FecIniClass)) as Mes
			,mat.[MATR_NumMat]
			,mat.[CLTE_CodCli]
			,cli.CLTE_Apellido
			,cli.CLTE_Nombre
			,cli.CLTE_EMail
			,cli.CLTE_Tel1
			--datos personales extendido
			,cli.CLTE_DocIden
			--,cli.CLTE_EMail
			--,cli.CLTE_Tel1
			,cli.[CLTE_Tel2]
			,cli.[CLTE_Celular]
			,cli.[CLTE_TelOfPadre]
			,cli.[CLTE_TelCelPadre]
			,cli.[CLTE_TelOfMadre]
			,cli.[CLTE_TelCelMadre]
			,cli.[CLTE_TelContacEmerg]
			,cli.[CLTE_CelContacEmerg]
			--,mat.[CROF_CodCurso]
			--,cof.CURS_CodCurso
			--,cof.HORA_CodHora
			--,cof.SALO_CodSalon
			--,cof.CROF_Estado
			,cof.CROF_Nombre
			--,cof.TRAB_Cod

			,mat.[CICL_CodCiclo]
			--,cic.TIPO_TCodTipoCiclo	
			--,cic.TIPO_CCodTipoCiclo
			--,cic.CICL_FecIni
			,cic.CICL_FecIniClass
			--,cic.CICL_FecFin
			,cic.CICL_Descripcion

			--,mat.[MATR_FecMat]
			--,mat.[MATR_Estado]
			,mat.[MATR_NotaFinal]
			,mat.[MATR_Aprobado]
into #tmp_matriculados_historial
from matriculas mat 
	inner join clientes				cli	on mat.clte_codcli		= cli.clte_codcli		and mat.[SUCR_CodSuc] = @Sede and cli.[SUCR_CodSuc] = @Sede
	INNER JOIN CICLOS				CIC	ON cic.CICL_CodCiclo	= mat.CICL_CodCiclo		and cic.[SUCR_CodSuc] = @Sede
	inner join cursosofrecidos		cof on cof.[CROF_CodCurso]	= mat.[CROF_CodCurso]	and cof.[SUCR_CodSuc] = @Sede
where mat.clte_codcli in (select clte_codcli from #tmp_matriculados_periodo)
and mat.[SUCR_CodSuc]	= @Sede
and mat.MATR_Estado		= 'C'
order by 
	mat.clte_codcli
	--,mat.MATR_NumMat
	,year(dateadd(day,10,cic.CICL_FecIniClass)) asc
	,month(dateadd(day,10,cic.CICL_FecIniClass)) asc

--select * from  #tmp_matriculados_historial



/******************************************************
3. meses transcurridos desde su matricula anterior
******************************************************/
	--primera matricula
	SELECT 0 as Meses_transucrridos_desde_matricula_anterior, * 
	into #tmp_matriculados_historial_completo
	FROM #tmp_matriculados_historial t1
	WHERE CICL_FecIniClass = (select MIN(CICL_FecIniClass)	from #tmp_matriculados_historial t2 where t2.CLTE_CodCli = t1.CLTE_CodCli)
	
	--resto de matriculas
	insert into #tmp_matriculados_historial_completo
	select 
		DATEDIFF(month, (
			SELECT TOP 1 CICL_FecIniClass FROM #tmp_matriculados_historial T2 WHERE T2.CICL_FecIniClass<T1.CICL_FecIniClass and t1.CLTE_CodCli = t2.CLTE_CodCli
			ORDER BY CICL_FecIniClass desc
			), t1.CICL_FecIniClass) AS Meses_transucrridos_desde_matricula_anterior
		,*
	from #tmp_matriculados_historial T1
	where DATEDIFF(month, (
			SELECT TOP 1 CICL_FecIniClass FROM #tmp_matriculados_historial T2 WHERE T2.CICL_FecIniClass<T1.CICL_FecIniClass and t1.CLTE_CodCli = t2.CLTE_CodCli
			ORDER BY CICL_FecIniClass desc
			), t1.CICL_FecIniClass) >= @Mesestranscurridos
			
--select * from #tmp_matriculados_historial_completo order by CLTE_CodCli, CICL_FecIniClass


/******************************************************
4.	REPORTE: Cantidad de matriculas que dejaron pasar N o mas meses desde su matricula anterior, desglosado por meses
		N = @Mesestranscurridos
******************************************************/
select 
	t1.Anio
	,t1.Mes
	,count(*) as Cantidad_matriculas
from #tmp_matriculados_historial_completo T1
where DATEDIFF(month, (
		SELECT TOP 1 CICL_FecIniClass FROM #tmp_matriculados_historial_completo T2 WHERE T2.CICL_FecIniClass<T1.CICL_FecIniClass and t1.CLTE_CodCli = t2.CLTE_CodCli
		ORDER BY CICL_FecIniClass desc
		), t1.CICL_FecIniClass) >= @Mesestranscurridos
	and (dateadd(day,10,t1.CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
group by t1.anio,t1.mes
order by 
	--CLTE_CodCli,
	t1.anio,t1.mes



/******************************************************
5.	REPORTE: Alumnos que volvieron despues de N o mas meses desde su matricula anterior
		N = @Mesestranscurridos
******************************************************/
select 
	*
from #tmp_matriculados_historial_completo T1
where DATEDIFF(month, (
		SELECT TOP 1 CICL_FecIniClass FROM #tmp_matriculados_historial_completo T2 WHERE T2.CICL_FecIniClass<T1.CICL_FecIniClass and t1.CLTE_CodCli = t2.CLTE_CodCli
		ORDER BY CICL_FecIniClass desc
		), t1.CICL_FecIniClass) >= @Mesestranscurridos
	and (dateadd(day,10,t1.CICL_FecIniClass)) between @FechaInicioCicloDesde and @FechaInicioCicloHasta
order by 
	t1.anio,t1.mes
	,CICL_CodCiclo
	,CROF_Nombre
