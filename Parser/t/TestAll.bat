@set PERL=C:\Perl\bin\perl
@set PFLAGS=-I ../../..

%PERL% %PFLAGS% testMyStream.t
@if errorlevel 1 goto error

%PERL% %PFLAGS% testState.t
@if errorlevel 1 goto error

@goto end
:error
@echo ÉGÉâÅ[!
:end
pause
