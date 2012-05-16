CFLAGS	=	-g
CSRC	=	$(wildcard *.c)
OBJS	=	$(CSRC:.c=.o)
DEPS	=	$(CSRC:.c=.d)
EXEC	=	generate


all:		$(EXEC)

$(EXEC):	$(OBJS) $(STATIC_C_AR)
	echo "**** Linking $@";
	$(CC) -o $@ $< -L$(STATIC_C_LIB_DIR) -l$(STATIC_C_LIB)

$(OBJS):	$(CSRC)
-include $(DEPS)
