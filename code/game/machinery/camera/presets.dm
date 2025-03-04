/obj/machinery/camera/network/engineering
	network = list(NETWORK_ENGINEERING, NETWORK_MASTER)

/obj/machinery/camera/network/ert
	network = list(NETWORK_ERT)

/obj/machinery/camera/network/medbay
	network = list(NETWORK_MEDICAL, NETWORK_MASTER)

/obj/machinery/camera/network/syndicate
	network = list(NETWORK_SYNDICATE)

/obj/machinery/camera/network/mining
	network = list(NETWORK_MINE)

/obj/machinery/camera/network/research
	network = list(NETWORK_RESEARCH, NETWORK_MASTER)

/obj/machinery/camera/network/security
	network = list(NETWORK_SECURITY, NETWORK_MASTER)

/obj/machinery/camera/network/thunder
	network = list(NETWORK_THUNDER)

/obj/machinery/camera/network/engineering/singularity
	network = list(NETWORK_ENGINE, NETWORK_MASTER)

// EMP

/obj/machinery/camera/emp_proof/Initialize()
	. = ..()
	upgradeEmpProof()

/obj/machinery/camera/network/engineering/singularity/Initialize()
	. = ..()
	upgradeEmpProof()

// X-RAY

/obj/machinery/camera/xray
	icon_state = "xraycam" // Thanks to Krutchen for the icons.

/obj/machinery/camera/xray/Initialize()
	. = ..()
	upgradeXRay()

// MOTION

/obj/machinery/camera/motion/Initialize()
	. = ..()
	upgradeMotion()

// ALL UPGRADES

/obj/machinery/camera/all/Initialize()
	. = ..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()

// AUTONAME left as a map stub
/obj/machinery/camera/autoname

// CHECKS

/obj/machinery/camera/proc/get_assembly()
	var/obj/item/camera_assembly/assembly = assembly_ref?.resolve()
	if(QDELETED(assembly))
		return null
	return assembly

/obj/machinery/camera/proc/isEmpProof()
	var/obj/item/camera_assembly/assembly = get_assembly()
	if(!assembly)
		return
	var/O = locate(/obj/item/stack/material/osmium) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	var/obj/item/camera_assembly/assembly = get_assembly()
	if(!assembly)
		return
	var/obj/item/stock_parts/scanning_module/O = locate(/obj/item/stock_parts/scanning_module) in assembly.upgrades
	if (O && O.rating >= 2)
		return O
	return null

/obj/machinery/camera/proc/isMotion()
	var/obj/item/camera_assembly/assembly = get_assembly()
	if(!assembly)
		return
	var/O = locate(/obj/item/device/assembly/prox_sensor) in assembly.upgrades
	return O

// UPGRADE PROCS

/obj/machinery/camera/proc/upgradeEmpProof()
	var/obj/item/camera_assembly/assembly = get_assembly()
	if(!assembly)
		return
	assembly.upgrades.Add(new /obj/item/stack/material/osmium(assembly))
	setPowerUsage()
	update_coverage()

/obj/machinery/camera/proc/upgradeXRay()
	var/obj/item/camera_assembly/assembly = get_assembly()
	if(!assembly)
		return
	assembly.upgrades.Add(new /obj/item/stock_parts/scanning_module/adv(assembly))
	setPowerUsage()
	update_coverage()

/obj/machinery/camera/proc/upgradeMotion()
	var/obj/item/camera_assembly/assembly = get_assembly()
	if(!assembly)
		return
	assembly.upgrades.Add(new /obj/item/device/assembly/prox_sensor(assembly))
	setPowerUsage()
	START_PROCESSING(SSmachines, src)
	update_coverage()

/obj/machinery/camera/proc/setPowerUsage()
	var/mult = 1
	if (isXRay())
		mult++
	if (isMotion())
		mult++
	change_power_consumption(mult*initial(active_power_usage), POWER_USE_ACTIVE)
