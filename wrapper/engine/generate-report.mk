# generate_component_report <component>
#
define generate_component_report
.PHONY:	$(strip $(1)).report

component-report:: $(strip $(1)).report

$(strip $(1)).report:
	$(ATSIGN)$(MESSAGE) "reporting on $(1)";

endef

