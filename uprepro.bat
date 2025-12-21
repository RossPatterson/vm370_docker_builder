@REM Script to update container repositories

@SET TAG=%~1
@SET REPO=rosspatterson

@IF "%TAG%" EQU "" (
	ECHO Syntax: %0 tagname
	EXIT /B 1
)

@REM Docker Tagging (builder, test and latest)
docker pull %REPO%/vm370:%TAG%

docker tag %REPO%/vm370:%TAG% %REPO%/vm370:builder
docker push %REPO%/vm370:builder

@REM docker tag %REPO%/vm370:%TAG% %REPO%/vm370:test
@REM docker push %REPO%/vm370:test

docker tag %REPO%/vm370:%TAG% %REPO%/vm370:latest
docker push %REPO%/vm370:latest
