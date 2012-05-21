# generate_component_report <component>
#
define generate_component_report
component-report:: $(strip $(1)).report

.PHONY:	$(strip $(1)).report

$(strip $(1)).report:
	@$(ECHO) "";
	@$(ECHO) "$(1)|Module      : $(call get,LMSBW_$(strip $(1)),module)";
	@$(ECHO) "$(1)|Component   : $(call get,LMSBW_$(strip $(1)),component)";
	@$(ECHO) "$(1)|Kind        : $(call get,LMSBW_$(strip $(1)),kind)";
	@$(ECHO) "$(1)|Reason      : $(call get,LMSBW_$(strip $(1)),reason)";
	@$(ECHO) "$(1)|Source      : $(call get,LMSBW_$(strip $(1)),source-directory)";
	@$(ECHO) "$(1)|Build       : $(call get,LMSBW_$(strip $(1)),build-directory)";
	@$(ECHO) "$(1)|DESTDIR     : $(call get,LMSBW_$(strip $(1)),destdir-directory)";
	@$(ECHO) "$(1)|sysroot     : $(call get,LMSBW_$(strip $(1)),sysroot-directory)";
	@$(ECHO) "$(1)|Prerequisite: $(call get,LMSBW_$(strip $(1)),prerequisite)";
	@$(ECHO) "";

endef

