extends Control
class_name InfoBox

func _ready() -> void:
    hide_all()

func display_simple(text: String) -> void:
    hide_all()
    $Simple/NinePatch/Label.text = text
    $Simple.show()

func display_plant_arch_id(id: String, can_afford: bool) -> void:
    hide_all()
    var arch: PlantArch = Plant.ARCHS[id]
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Name.text = arch.name
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Cost/Label.text = str(arch.grow_cost)
    if can_afford:
        $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Cost/Label.modulate = Color.white
    else:
        $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Cost/Label.modulate = Color.red
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Charges/Label.text = "%d @ %d days" % [arch.spell_charges, arch.growth_period]
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/GridContainer/Watering/Label.text = "%d / %d days" % [arch.watering_quantity, arch.watering_frequency]
    $PlantArch/NinePatch/MarginContainer/VBoxContainer/Description.text = arch.description
    $PlantArch.show()

func display_plant(plant: Plant) -> void:
    $Plant.show()

func hide_all() -> void:
    for node in get_children():
        node.hide()
