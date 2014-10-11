
!include Make.rules

TESTS = $(BINDIR)\test1$(CPUSFX).exe

ALL: $(TESTS)
	
$(BINDIR)\test1$(CPUSFX).exe: test1.cpp $(rtlpp)
	echo %%LIB%%
	cl $(CXXFLAGS) -Fe$@ test1.cpp $(LIBRARIES) $(LINKOPTS)

clean::
	-del /q $(TESTS)
