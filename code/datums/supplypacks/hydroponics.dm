/decl/hierarchy/supply_pack/hydroponics
	name = "Hydroponics"
	containertype = /obj/structure/closet/crate/hydroponics

/decl/hierarchy/supply_pack/hydroponics/monkey
	name = "Monkey crate"
	contains = list (/obj/item/storage/box/monkeycubes)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper Monkey crate"

/decl/hierarchy/supply_pack/hydroponics/farwa
	name = "Farwa crate"
	contains = list (/obj/item/storage/box/monkeycubes/farwacubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper Farwa crate"

/decl/hierarchy/supply_pack/hydroponics/neaera
	name = "Neaera crate"
	contains = list (/obj/item/storage/box/monkeycubes/neaeracubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper Neaera crate"

/decl/hierarchy/supply_pack/hydroponics/stok
	name = "Stok crate"
	contains = list (/obj/item/storage/box/monkeycubes/stokcubes)
	cost = 30
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper Stok crate"

/decl/hierarchy/supply_pack/hydroponics/corgi
	name = "Corgi crate"
	contains = list(/mob/living/simple_animal/corgi)
	cost = 50
	containertype = /obj/structure/largecrate/animal/corgi
	containername = "\improper Corgi crate"

/decl/hierarchy/supply_pack/hydroponics/parrot
	name = "Parrot crate"
	contains = list(/mob/living/simple_animal/parrot)
	cost = 40
	containertype = /obj/structure/largecrate/animal/parrot
	containername = "\improper Parrot crate"

//farm animals - useless and annoying, but potentially a good source of food. expensive because they're live animals and their produce is available cheaper
/decl/hierarchy/supply_pack/hydroponics/cow
	name = "Cow crate"
	contains = list(/mob/living/simple_animal/cow)
	cost = 80
	containertype = /obj/structure/largecrate/animal/cow
	containername = "\improper Cow crate"
	access = access_hydroponics

/decl/hierarchy/supply_pack/hydroponics/goat
	name = "Goat crate"
	contains = list(/mob/living/simple_animal/hostile/retaliate/goat)
	cost = 75
	containertype = /obj/structure/largecrate/animal/goat
	containername = "\improper Goat crate"
	access = access_hydroponics

/decl/hierarchy/supply_pack/hydroponics/chicken
	name = "Chicken crate"
	contains = list(/mob/living/simple_animal/chick = 5)
	cost = 70
	containertype = /obj/structure/largecrate/animal/chick
	containername = "\improper Chicken crate"
	access = access_hydroponics

/decl/hierarchy/supply_pack/hydroponics/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/reagent_containers/spray/plantbgone = 4,
					/obj/item/reagent_containers/glass/bottle/ammonia = 2,
					/obj/item/material/hatchet,
					/obj/item/material/minihoe,
					/obj/item/device/analyzer/plant_analyzer,
					/obj/item/clothing/gloves/thick/botany,
					/obj/item/clothing/suit/apron,
					/obj/item/shovel/spade,
					/obj/item/storage/box/botanydisk
					)
	cost = 15
	containername = "\improper Hydroponics crate"
	access = access_hydroponics

/decl/hierarchy/supply_pack/hydroponics/seeds
	name = "Seeds crate"
	contains = list(/obj/item/seeds/chiliseed,
					/obj/item/seeds/berryseed,
					/obj/item/seeds/cornseed,
					/obj/item/seeds/eggplantseed,
					/obj/item/seeds/tomatoseed,
					/obj/item/seeds/appleseed,
					/obj/item/seeds/soyaseed,
					/obj/item/seeds/wheatseed,
					/obj/item/seeds/carrotseed,
					/obj/item/seeds/harebell,
					/obj/item/seeds/lemonseed,
					/obj/item/seeds/orangeseed,
					/obj/item/seeds/grassseed,
					/obj/item/seeds/sunflowerseed,
					/obj/item/seeds/chantermycelium,
					/obj/item/seeds/potatoseed,
					/obj/item/seeds/sugarcaneseed)
	cost = 10
	containername = "\improper Seeds crate"
	access = access_hydroponics

/decl/hierarchy/supply_pack/hydroponics/weedcontrol
	name = "Weed control crate"
	contains = list(/obj/item/material/hatchet = 2,
					/obj/item/reagent_containers/spray/plantbgone = 4,
					/obj/item/clothing/mask/gas = 2,
					/obj/item/grenade/chem_grenade/antiweed = 2)
	cost = 25
	containername = "\improper Weed control crate"
	access = access_hydroponics

/decl/hierarchy/supply_pack/hydroponics/exoticseeds
	name = "Exotic seeds crate"
	contains = list(/obj/item/seeds/replicapod = 2,
					/obj/item/seeds/libertymycelium,
					/obj/item/seeds/reishimycelium,
					/obj/item/seeds/random = 6,
					/obj/item/seeds/kudzuseed)
	cost = 15
	containertype = /obj/structure/closet/crate/secure
	containername = "\improper Exotic Seeds crate"
	access = access_xenobiology

/decl/hierarchy/supply_pack/hydroponics/watertank
	name = "Water tank crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "\improper water tank crate"

/decl/hierarchy/supply_pack/hydroponics/composttank
	name = "Compost tank crate"
	contains = list(/obj/structure/reagent_dispensers/composttank)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "\improper compost tank crate"

/decl/hierarchy/supply_pack/hydroponics/bee_keeper
	name = "Beekeeping crate"
	contains = list(/obj/item/beehive_assembly,
					/obj/item/bee_smoker,
					/obj/item/honey_frame = 5,
					/obj/item/bee_pack)
	cost = 40
	containername = "\improper Beekeeping crate"
	access = access_hydroponics

/decl/hierarchy/supply_pack/hydroponics/hydrotray
	name = "Empty hydroponics tray"
	contains = list(/obj/machinery/portable_atmospherics/hydroponics{anchored = 0})
	cost = 30
	containertype = /obj/structure/closet/crate/large/hydroponics
	containername = "\improper Hydroponics tray crate"
	access = access_hydroponics

/decl/hierarchy/supply_pack/hydroponics/pottedplant
	name = "Potted plant crate"
	num_contained = 2
	contains = list(/obj/structure/flora/pottedplant,
					/obj/structure/flora/pottedplant/large,
					/obj/structure/flora/pottedplant/fern,
					/obj/structure/flora/pottedplant/overgrown,
					/obj/structure/flora/pottedplant/bamboo,
					/obj/structure/flora/pottedplant/largebush,
					/obj/structure/flora/pottedplant/thinbush,
					/obj/structure/flora/pottedplant/mysterious,
					/obj/structure/flora/pottedplant/smalltree,
					/obj/structure/flora/pottedplant/unusual,
					/obj/structure/flora/pottedplant/orientaltree,
					/obj/structure/flora/pottedplant/smallcactus,
					/obj/structure/flora/pottedplant/tall,
					/obj/structure/flora/pottedplant/sticky,
					/obj/structure/flora/pottedplant/smelly,
					/obj/structure/flora/pottedplant/small,
					/obj/structure/flora/pottedplant/aquatic,
					/obj/structure/flora/pottedplant/shoot,
					/obj/structure/flora/pottedplant/flower,
					/obj/structure/flora/pottedplant/crystal,
					/obj/structure/flora/pottedplant/subterranean,
					/obj/structure/flora/pottedplant/minitree,
					/obj/structure/flora/pottedplant/stoutbush,
					/obj/structure/flora/pottedplant/drooping,
					/obj/structure/flora/pottedplant/tropical,
					/obj/structure/flora/pottedplant/dead,
					/obj/structure/flora/pottedplant/decorative)
	cost = 6
	containertype = /obj/structure/closet/crate/large/hydroponics
	containername = "\improper Potted plant crate"
	supply_method = /decl/supply_method/randomized
