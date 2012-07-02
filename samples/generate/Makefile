CFLAGS	=	-g
CSRC	=	$(wildcard *.c)
OBJS	=	$(CSRC:.c=.o)
DEPS	=	$(CSRC:.c=.d)
EXEC	=	generate


all:		$(EXEC)

$(EXEC):	$(OBJS) $(STATIC_C_AR)
	$(CC) -o $@ $< -L$(STATIC_C_LIB_DIR) -l$(STATIC_C_LIB)

$(OBJS):	$(CSRC)


clean:
	rm -f $(OBJS) $(EXEC)

-include $(DEPS)
