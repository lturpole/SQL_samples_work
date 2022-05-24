
/******************************************************
Alumnos que se matricularon en un intervalo de tiempo y que no volvieron en un mes X(Este mes)
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
SET @FechaInicioCicloDesde	= '2020/08/01';
SET @FechaInicioCicloHasta	= '2021/04/20';
SET @Mesestranscurridos		= 0; --igual o mayor //meses transcurridos desde su matricula anterior (usar 0 para todas sus matriculas)
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
and MATR_Aprobado		= @Aprobado
--and mat.clte_codcli in ('003508')
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
4. REPORTE: Matriculados en los intervalos A y B que no volvieron este mes
		A = @FechaInicioCicloDesde
		B = @FechaInicioCicloHasta
******************************************************/
SELECT 
	A.SUCR_CodSuc,
	--A.Anio,
	--A.Mes,
	--A.MATR_NumMat,
	A.CLTE_CodCli,
	A.CLTE_Apellido,
	A.CLTE_Nombre,
	A.CLTE_EMail,
	A.CLTE_Tel1,
	A.CLTE_DocIden,
	A.CLTE_Tel2,
	A.CLTE_Celular,
	A.CLTE_TelOfPadre,
	A.CLTE_TelCelPadre,
	A.CLTE_TelOfMadre,
	A.CLTE_TelCelMadre,
	A.CLTE_TelContacEmerg,
	A.CLTE_CelContacEmerg,
	A.CROF_Nombre,
	--A.CICL_CodCiclo,
	--A.CICL_FecIniClass,
	A.CICL_Descripcion as Ultimo_curso_llevado,
	A.MATR_NotaFinal,
	A.MATR_Aprobado
FROM	(
			--Las ultimas matriculas de cada alumno
			SELECT		
				 *
			FROM		#tmp_matriculados_historial
			WHERE		MATR_NumMat in (SELECT max(MATR_NumMat) FROM #tmp_matriculados_historial group by CLTE_CodCli)
		)		A
    
--Le quito los matriculados de este mes (para que quede la lista de alumnos que se matricularon antes y no en este mes)
LEFT JOIN 
		(	
			--Matriculados de este mes en adelante
			SELECT		MAT.CLTE_CodCli 
			FROM		MATRICULAS			MAT
			INNER JOIN	CICLOS				CIC		ON	cic.CICL_CodCiclo	= mat.CICL_CodCiclo
			WHERE 
				--CLTE_CodCli   = '009915' and
				mat.MATR_Estado		= 'C' and
				
				--matriculados este mes solamente
				/*year(dateadd(day,10,CIC.CICL_FecIniClass))		= year(getdate())
				and month(dateadd(day,10,CIC.CICL_FecIniClass))	= month(getdate())*/
				
				--matriculados de este mes en adelante
				dateadd(day,10,CIC.CICL_FecIniClass) > cast(year	(getdate()) as varchar(4)) + '-' +	right ('00'+ltrim(str( month(getdate()) )),2 ) + '-' +	'01' --select (year(getdate()) + month(getdate()) + '01')
		)		B
ON A.CLTE_CodCli = B.CLTE_CodCli
WHERE 
	B.CLTE_CodCli IS NULL
	and matr_aprobado = 'A'
	and (
		A.CICL_Descripcion like '%semana%'	or
		A.CICL_Descripcion like '%Intensivo%'	or
		A.CICL_Descripcion like '%diario%'	or
		A.CICL_Descripcion like '%regular%'	or
		A.CICL_Descripcion like '%Superintensivo%'	or
		A.CICL_Descripcion like '%Weekend%' or
		A.CICL_Descripcion like '%Profesionales%' or
		A.CICL_Descripcion like '%efectiva%'
		)
order by 
	A.CICL_CodCiclo,
	A.CROF_Nombre,
	A.CLTE_Apellido,
	A.CLTE_Nombre

