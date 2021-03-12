extends Control
class_name InfoBox

func _ready() -> void:
    hide_all()

func display_simple(text: String) -> void:
    hide_all()
    $Simple/NinePatch/Label.text = text
    $Simple.show()

func display_plant_kind(kind: int, can_afford: bool) -> void:
    hide_all()
    var res: PlantResource = Plant.KIND_RESOURCES[kind]
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Name.text = res.name
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Cost/Label.text = str(res.grow_cost)
    if can_afford:
        $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Cost/Label.modulate = Color.white
    else:
        $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Cost/Label.modulate = Color.red
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/GrowthPeriod/Label.text = str(res.growth_period)
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/WateringQuantity/Label.text = str(res.watering_quantity)
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/WateringFrequency/Label.text = str(res.watering_frequency)
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/Description.text = res.description
    $PlantArch.show()

func display_plant(plant: Plant) -> void:
    hide_all()
    var res: PlantResource = plant.get_resource()
    $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/Name.text = res.name
    $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/WaterNeeded/Label.text = str(plant.get_water_needed())
    if plant.needs_water():
        $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/WaterNeeded/Label.modulate = Color.red
    else:
        $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/WaterNeeded/Label.modulate = Color.white
    $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/Age/Label.text = str(plant.get_age())
    $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/Stage/Label.text = str(plant.get_stage())
    $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/Charges/Label.text = str(plant.get_charges())
    $Plant/NinePatch/MarginContainer/VBoxContainer/Description.text = res.spell_description
    $Plant.show()

func hide_all() -> void:
    for node in get_children():
        node.hide()
