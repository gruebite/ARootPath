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
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/Title/Name.text = res.name
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/Title/Cost.text = str(res.grow_cost)
    if can_afford:
        $PlantArch/NinePatch/MarginContainer/VBoxContainer/Title/Cost.modulate = Color.white
    else:
        $PlantArch/NinePatch/MarginContainer/VBoxContainer/Title/Cost.modulate = Color.red
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/GrowthPeriod.text = str(res.growth_period)
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/WateringQuantity.text = str(res.watering_quantity)
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/WateringFrequency.text = str(res.watering_frequency)
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/Description.text = res.description
    $PlantArch.show()

func display_plant(plant: Plant) -> void:
    hide_all()
    var res: PlantResource = plant.get_resource()
    $Plant/NinePatch/MarginContainer/VBoxContainer/Title/Name.text = res.name
    if plant.get_water_needed() <= GameState.water:
        $Plant/NinePatch/MarginContainer/VBoxContainer/Title/WaterNeeded.modulate = Color.white
    else:
        $Plant/NinePatch/MarginContainer/VBoxContainer/Title/WaterNeeded.modulate = Color.red
    $Plant/NinePatch/MarginContainer/VBoxContainer/Title/WaterNeeded.text = str(plant.get_water_needed())
    if plant.needs_water():
        $Plant/NinePatch/MarginContainer/VBoxContainer/Title/Name.modulate = Color.red
    else:
        $Plant/NinePatch/MarginContainer/VBoxContainer/Title/Name.modulate = Color.white
    $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/Age.text = str(plant.get_age())
    $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/LastWatered.text = str(plant.get_last_watered())
    $Plant/NinePatch/MarginContainer/VBoxContainer/GridContainer/Charges.text = str(plant.get_charges())
    $Plant/NinePatch/MarginContainer/VBoxContainer/Description.text = res.description
    $Plant.show()

func hide_all() -> void:
    for node in get_children():
        node.hide()
