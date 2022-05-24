/*******************************************
* TODOS LOS ALUMNOS CON PROMEDIO MAYOR A 95 
* durante toda su permanencia en el cultural
* que hayan llevado entre 3 a 5 ciclos consecutivos
* que esten matriculados actualmente
* que tengan una fase/nivel previo aprobado
*******************************************/

USE CCPNA;
/*DECLARE @CodUsr varchar(6);

DECLARE @Nombre varchar(50);
DECLARE @Apellido varchar(50);*/
/*SET @CodUsr		= '127347';
SET @Nombre		= '%pedro%';
SET @Apellido	= '%guillen leva%';*/
DECLARE @Sede		varchar(2);
DECLARE @Promedio	int;
DECLARE @Ciclo		int;
DECLARE @Meses		int;
DECLARE @Niveles	int;
--1271 --Mayo	5 meses -> 32 personas mayores de 95 y 2 de 99
--1278 --Junio	4 meses -> 30 personas mayores de 95 y 3 de 99
--1284 --Julio	3 meses -> 28 personas mayores de 95 y 1 de 99
SET @Sede		= '01';
SET @Promedio	= 95
SET @Ciclo		= 1278	--A partir de este ciclo
SET @meses		= 4		--#matriculas
SET @Niveles	= 2
/*******************************************/
SELECT
	PROMEDIOS.CodCli
	,PROMEDIOS.Apellido
	,PROMEDIOS.Nombre
	,PROMEDIOS.Promedio
	--,PROMEDIOS.Acumulado
	--,PROMEDIOS.Total_ciclos
	,NIVELES.Fases as Niveles
	,PROMEDIOS.Edad
	,PROMEDIOS.CLTE_DocIden			AS Documento
	,PROMEDIOS.CLTE_Dir1			AS Direccion
	,PROMEDIOS.CLTE_EMail			AS Email
	,PROMEDIOS.CLTE_Celular			AS Celular
	,PROMEDIOS.CLTE_ContacEmerg		AS Contacto_de_emergencia
	,PROMEDIOS.CLTE_TelContacEmerg	AS Telefono_de_contacto_de_emergencia
	
FROM 
	(
	SELECT 
	T02.CLTE_CodCli				AS CodCli
	,T02.CLTE_Apellido			AS Apellido
	,T02.CLTE_Nombre			AS Nombre
	,avg(T02.MATR_NotaFinal)	AS Promedio
	,sum(T02.MATR_NotaFinal)	AS Acumulado
	,count(T02.MATR_NotaFinal)	AS Total_ciclos
	,T02.Edad
	,T02.CLTE_DocIden
	,T02.CLTE_Dir1
	,T02.CLTE_EMail
	,T02.CLTE_Celular
	,T02.CLTE_ContacEmerg
	,T02.CLTE_TelContacEmerg

	FROM
		(
		SELECT 
			T01.SUCR_CodSuc
			,T01.MATR_NumMat
			,T01.CLTE_CodCli
			,T01.CLTE_Apellido
			,T01.CLTE_Nombre
			,T01.Edad
			,T01.CLTE_DocIden
			,T01.CLTE_Dir1
			,T01.CLTE_EMail
			,T01.CLTE_Celular
			,T01.CLTE_ContacEmerg
			,T01.CLTE_TelContacEmerg
			
			,T01.CROF_CodCurso
			,T01.CURS_CodCurso
			,T01.CROF_Estado
			,T01.CROF_Nombre
			,T01.CICL_CodCiclo
			,T01.TIPO_TCodTipoCiclo
			,T01.TIPO_CCodTipoCiclo
			,T01.CICL_FecIniClass
			,t01.CICL_FecFin
			,T01.CICL_Descripcion

			,T01.MATR_FecMat
			,T01.MATR_Estado
			,T01.MATR_NotaFinal
			,T01.MATR_Aprobado

			,TIP.TIPO_CodTabla
			,TIP.TIPO_CodTipo
			,TIP.TIPO_Desc1
			,TIP.TIPO_Desc2
			,TIP.TIPO_DescC
			
			
			,CUR.CARR_CodCarr
			,CUR.CURS_Nombre
			,CUR.TIPO_TabFase
			,CUR.TIPO_CodFase
			,CUR.CURS_Descripcion	
			
		FROM
			(
			SELECT 
				mat.[SUCR_CodSuc]
				,mat.[MATR_NumMat]
				,mat.[CLTE_CodCli]
				,cli.CLTE_Apellido
				,cli.CLTE_Nombre
				,cast(datediff(dd,cli.CLTE_FecNac,GETDATE()) / 365.25 as int) as Edad
				,cli.CLTE_DocIden
				,cli.CLTE_Dir1
				,cli.CLTE_EMail
				,cli.CLTE_Celular
				,cli.CLTE_ContacEmerg
				,cli.CLTE_TelContacEmerg
				--select top 100 * from clientes WHERE CLTE_CodCli = 127347
				

				,mat.[CROF_CodCurso]
				,cof.CURS_CodCurso
				,cof.CROF_Estado
				,cof.CROF_Nombre

				,mat.[CICL_CodCiclo]
				,cic.TIPO_TCodTipoCiclo	
				,cic.TIPO_CCodTipoCiclo
				,cic.CICL_FecIniClass
				,cic.CICL_FecFin
				,cic.CICL_Descripcion

				,mat.[MATR_FecMat]
				,mat.[MATR_Estado]
				,mat.[MATR_NotaFinal]
				,mat.[MATR_Aprobado]
				
			FROM [CCPNA].[dbo].[Matriculas]	mat
				INNER JOIN clientes				cli ON cli.[CLTE_CodCli]	= mat.[CLTE_CodCli]		and cli.[SUCR_CodSuc]	= 01
				INNER JOIN ciclos				cic ON cic.cicl_codciclo	= mat.cicl_codciclo		and cic.[SUCR_CodSuc]	= 01		and CICL_Estado = 'C'
				INNER JOIN cursosofrecidos		cof ON cof.[CROF_CodCurso]	= mat.[CROF_CodCurso]	and cof.[SUCR_CodSuc]	= 01
			WHERE
				--mat.[CLTE_CodCli]	= @CodUsr	and 
				--mat.[SUCR_CodSuc]	= 01	and mat.matr_estado = 'C' and cic.CICL_CodCiclo >= 1271 --Mayo
				--mat.[SUCR_CodSuc]	= 01	and mat.matr_estado = 'C' and cic.CICL_CodCiclo >= 1278 --Junio
				--mat.[SUCR_CodSuc]	= 01	and mat.matr_estado = 'C' and cic.CICL_CodCiclo >= 1284 --Julio
				mat.[SUCR_CodSuc]	= 01	and mat.matr_estado = 'C' and cic.CICL_CodCiclo >= @Ciclo --Julio
			) as t01
			INNER JOIN tipos		tip ON tip.tipo_codtipo		= t01.TIPO_CCodTipoCiclo	AND TIP.TIPO_CODTABLA	= T01.TIPO_TCodTipoCiclo
			INNER JOIN CURSOS		CUR ON CUR.CURS_CodCurso	= T01.CURS_CodCurso			AND CUR.[SUCR_CodSuc]	= 01
		) AS t02
		INNER JOIN carreras	car ON car.CARR_CodCarr		= t02.CARR_CodCarr			AND car.[SUCR_CodSuc]	= 01
		INNER JOIN TIPOS	TIP ON TIP.TIPO_CODTIPO		= T02.TIPO_CodFase			AND TIP.TIPO_CODTABLA	= T02.TIPO_TabFase
	GROUP BY
		T02.CLTE_CodCli		--AS CodCli
		,T02.CLTE_Apellido	--AS Apellido
		,T02.CLTE_Nombre	--AS Nombre
		,T02.Edad			--AS Nombre
		,T02.CLTE_DocIden
		,T02.CLTE_Dir1
		,T02.CLTE_EMail
		,T02.CLTE_Celular
		,T02.CLTE_ContacEmerg
		,T02.CLTE_TelContacEmerg
	/*order by 
		T02.CLTE_CodCli		desc*/
	) AS PROMEDIOS
	INNER JOIN 
	(

	SELECT
	T02.CLTE_CodCli	AS CodCli
	--,T02.CLTE_Apellido	AS Apellido
	--,T02.CLTE_Nombre	AS Nombre
	--,TIP.TIPO_Desc1		AS Fase
	,COUNT(DISTINCT TIP.TIPO_Desc1)		AS Fases
		
	FROM
	(
	select 
		
		T01.SUCR_CodSuc
		,T01.MATR_NumMat
		,T01.CLTE_CodCli
		,T01.CLTE_Apellido
		,T01.CLTE_Nombre
		,T01.CLTE_EMail
		,T01.CLTE_Tel1
		,T01.CROF_CodCurso
		,T01.CURS_CodCurso
		,T01.SALO_CodSalon
		,T01.CROF_Estado
		,T01.CROF_Nombre
		,T01.CICL_CodCiclo
		,T01.TIPO_TCodTipoCiclo
		,T01.TIPO_CCodTipoCiclo
		,T01.CICL_FecIniClass
		,t01.CICL_FecFin
		,T01.CICL_Descripcion

		,T01.MATR_FecMat
		,T01.MATR_Estado
		,T01.MATR_NotaFinal
		,T01.MATR_Aprobado

		,TIP.TIPO_CodTabla
		,TIP.TIPO_CodTipo
		,TIP.TIPO_Desc1
		,TIP.TIPO_Desc2
		,TIP.TIPO_DescC
		/*
		,SALO_DESCRIPCION
		,HOR.HORA_Inicio
		,HOR.HORA_Fin
		*/
		,CUR.CARR_CodCarr
		,CUR.CURS_Nombre
		,CUR.TIPO_TabFase
		,CUR.TIPO_CodFase
		,CUR.CURS_Descripcion	
		/*
		,TRA.TRAB_Nombre1
		,TRA.TRAB_Apellido1*/
		
		from
			(
			SELECT 
				mat.[SUCR_CodSuc]
				,mat.[MATR_NumMat]
				,mat.[CLTE_CodCli]
				,cli.CLTE_Apellido
				,cli.CLTE_Nombre
				,cli.CLTE_EMail
				,cli.CLTE_Tel1

				,mat.[CROF_CodCurso]
				,cof.CURS_CodCurso
				,cof.HORA_CodHora
				,cof.SALO_CodSalon
				,cof.CROF_Estado
				,cof.CROF_Nombre
				,cof.TRAB_Cod

				,mat.[CICL_CodCiclo]
				,cic.TIPO_TCodTipoCiclo	
				,cic.TIPO_CCodTipoCiclo
				,cic.CICL_FecIniClass
				,cic.CICL_FecFin
				,cic.CICL_Descripcion

				,mat.[MATR_FecMat]
				,mat.[MATR_Estado]
				,mat.[MATR_NotaFinal]
				,mat.[MATR_Aprobado]
				
				
			FROM [CCPNA].[dbo].[Matriculas]	mat
				INNER JOIN clientes				cli ON cli.[CLTE_CodCli]	= mat.[CLTE_CodCli]		and cli.[SUCR_CodSuc]	= 01
				INNER JOIN ciclos				cic ON cic.[cicl_codciclo]	= mat.[cicl_codciclo]	and cic.[SUCR_CodSuc]	= 01		--and CICL_Estado = 'C'
				INNER JOIN cursosofrecidos		cof ON cof.[CROF_CodCurso]	= mat.[CROF_CodCurso]	and cof.[SUCR_CodSuc]	= 01
			WHERE 
				mat.[SUCR_CodSuc]	= 01		and mat.matr_estado = 'C' and cic.CICL_CodCiclo >= @Ciclo --Julio
			) as t01
		INNER JOIN tipos		tip ON tip.tipo_codtipo		= t01.TIPO_CCodTipoCiclo	AND TIP.TIPO_CODTABLA	= T01.TIPO_TCodTipoCiclo
		INNER JOIN CURSOS		CUR ON CUR.CURS_CodCurso	= T01.CURS_CodCurso			AND CUR.[SUCR_CodSuc]	= 01 AND CURS_Nombre <> 'EXC'
	) AS t02
	INNER JOIN carreras	car ON car.CARR_CodCarr		= t02.CARR_CodCarr
	INNER JOIN TIPOS	TIP ON TIP.TIPO_CODTIPO		= T02.TIPO_CodFase			AND TIP.TIPO_CODTABLA	= T02.TIPO_TabFase

	GROUP BY 
		T02.CLTE_CodCli		--AS CodCli
		,T02.CLTE_Apellido	--AS Apellido
		,T02.CLTE_Nombre	--AS Nombre
		--,TIP.TIPO_Desc1		--AS Fase
	/*order by 
		COUNT(DISTINCT TIP.TIPO_Desc1) DESC
		,T02.CLTE_CodCli	desc--AS CodCli
*/
	) AS NIVELES
	ON PROMEDIOS.CodCli = NIVELES.CodCli
WHERE 
	PROMEDIOS.Promedio	>= @Promedio
	and Total_ciclos	>= @Meses
	and Fases			>= @Niveles
order by PROMEDIOS.Promedio desc





