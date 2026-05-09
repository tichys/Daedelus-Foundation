/obj/item/encryptionkey/scp_command
	name = "Foundation Command encryption key"
	icon_state = "com_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/scp_security
	name = "Foundation Security encryption key"
	icon_state = "sec_cypherkey"
	channels = list("Security" = 1)

/obj/item/encryptionkey/scp_science
	name = "Foundation Science encryption key"
	icon_state = "sci_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/scp_medical
	name = "Foundation Medical encryption key"
	icon_state = "med_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1)

/obj/item/encryptionkey/scp_engineering
	name = "Foundation Engineering encryption key"
	icon_state = "eng_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1)

/obj/item/encryptionkey/scp_containment
	name = "Foundation Containment encryption key"
	icon_state = "cent_cypherkey"
	channels = list("Containment" = 1)

/obj/item/encryptionkey/scp_mtf
	name = "Foundation MTF encryption key"
	icon_state = "syn_cypherkey"
	channels = list("MTF" = 1)

/obj/item/encryptionkey/scp_ci
	name = "Chaos Insurgency encryption key"
	icon_state = "syn_cypherkey"
	channels = list(RADIO_CHANNEL_SYNDICATE = 1)
	syndie = TRUE

/obj/item/radio/headset/scp_command
	name = "Foundation command headset"
	desc = "A headset with access to all SCP Foundation channels."
	icon_state = "com_headset"
	keyslot = /obj/item/encryptionkey/scp_command

/obj/item/radio/headset/scp_command/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SCP_COMMAND)
	listening += FREQ_SCP_SECURITY
	listening += FREQ_SCP_SCIENCE
	listening += FREQ_SCP_MEDICAL
	listening += FREQ_SCP_CONTAINMENT
	listening += FREQ_SCP_MTF
	listening += FREQ_SCP_ENGINEERING

/obj/item/radio/headset/scp_security
	name = "Foundation security headset"
	desc = "A headset tuned to SCP Foundation security channels."
	icon_state = "sec_headset"
	keyslot = /obj/item/encryptionkey/scp_security

/obj/item/radio/headset/scp_security/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SCP_SECURITY)
	listening += FREQ_SCP_COMMAND
	listening += FREQ_SCP_CONTAINMENT
	listening += FREQ_SCP_MTF

/obj/item/radio/headset/scp_science
	name = "Foundation science headset"
	desc = "A headset tuned to SCP Foundation research channels."
	icon_state = "sci_headset"
	keyslot = /obj/item/encryptionkey/scp_science

/obj/item/radio/headset/scp_science/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SCP_SCIENCE)
	listening += FREQ_SCP_COMMAND
	listening += FREQ_SCP_CONTAINMENT

/obj/item/radio/headset/scp_medical
	name = "Foundation medical headset"
	desc = "A headset tuned to SCP Foundation medical channels."
	icon_state = "med_headset"
	keyslot = /obj/item/encryptionkey/scp_medical

/obj/item/radio/headset/scp_medical/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SCP_MEDICAL)
	listening += FREQ_SCP_COMMAND

/obj/item/radio/headset/scp_engineering
	name = "Foundation engineering headset"
	desc = "A headset tuned to SCP Foundation engineering channels."
	icon_state = "eng_headset"
	keyslot = /obj/item/encryptionkey/scp_engineering

/obj/item/radio/headset/scp_engineering/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SCP_ENGINEERING)
	listening += FREQ_SCP_COMMAND

/obj/item/radio/headset/scp_containment
	name = "Foundation containment headset"
	desc = "A headset tuned to SCP Foundation containment channels."
	icon_state = "sec_headset"
	keyslot = /obj/item/encryptionkey/scp_containment

/obj/item/radio/headset/scp_containment/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SCP_CONTAINMENT)
	listening += FREQ_SCP_COMMAND
	listening += FREQ_SCP_SECURITY
	listening += FREQ_SCP_SCIENCE

/obj/item/radio/headset/scp_mtf
	name = "MTF tactical headset"
	desc = "A headset with MTF tactical channels."
	icon_state = "sec_headset"
	keyslot = /obj/item/encryptionkey/scp_mtf

/obj/item/radio/headset/scp_mtf/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SCP_MTF)
	listening += FREQ_SCP_COMMAND
	listening += FREQ_SCP_SECURITY
	listening += FREQ_SCP_CONTAINMENT

/obj/item/radio/headset/scp_dclass
	name = "D-Class headset"
	desc = "A basic headset with limited Foundation channels."
	icon_state = "headset"
	keyslot = null

/obj/item/radio/headset/scp_dclass/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SCP_DCLASS)
	listening += FREQ_COMMON

/obj/item/radio/headset/scp_ci
	name = "Chaos Insurgency headset"
	desc = "A headset with encrypted CI channels."
	icon_state = "syndie"
	keyslot = /obj/item/encryptionkey/scp_ci

/obj/item/radio/headset/scp_ci/Initialize(mapload)
	. = ..()
	make_syndie()
