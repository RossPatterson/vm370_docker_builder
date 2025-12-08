@REM Script to update container repositories

SET TAG=2.0.0
SET REPO=rosspatterson

@REM Docker Tagging (builder, test and latest)
docker pull %REPO%/vm370:%TAG%

docker tag %REPO%/vm370:%TAG% %REPO%/vm370:builder
docker push %REPO%/vm370:builder

@REM docker tag %REPO%/vm370:%TAG% %REPO%/vm370:test
@REM docker push %REPO%/vm370:test

docker tag %REPO%/vm370:%TAG% %REPO%/vm370:latest
docker push %REPO%/vm370:latest
