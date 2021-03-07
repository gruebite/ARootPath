extends Resource
class_name Walker

const DIR8 = [
    Vector2( 0, -1),
    Vector2( 1, -1),
    Vector2( 1,  0),
    Vector2( 1,  1),
    Vector2( 0,  1),
    Vector2(-1,  1),
    Vector2(-1,  0),
    Vector2(-1, -1),
]

# Maintains a randomly accessible point set.
class PointSet:
    var array := []

    func has(x: int, y: int) -> bool:
        return hasv(Vector2(x, y))

    func hasv(pos: Vector2) -> bool:
        var idx := array.bsearch(pos)
        return idx < len(array) && array[idx] == pos

    func length() -> int:
        return len(array)

    func clear() -> void:
        array.clear()

    func add(x: int, y: int) -> void:
        var pos := Vector2(x, y)
        addv(pos)

    func addv(pos: Vector2) -> void:
        var idx := array.bsearch(pos)
        if idx < len(array) && array[idx] == pos:
            return
        array.insert(idx, pos)

    func rem(x: int, y: int) -> void:
        var pos := Vector2(x, y)
        remv(pos)

    func remv(pos: Vector2) -> void:
        var idx := array.bsearch(pos)
        if idx < len(array) && array[idx] == pos:
            array.remove(idx)

    func random(rng: RandomNumberGenerator) -> Vector2:
        var i = rng.randi_range(0, len(array) - 1)
        return array[i]

# Flags for overwriting when commiting marks.
enum {
    MARK_OPENED_OVER_OPENED = 1,
    MARK_OPENED_OVER_CLOSED = 2,
    MARK_CLOSED_OVER_OPENED = 4,
    MARK_CLOSED_OVER_CLOSED = 8,
    MARK_OVER_OPENED = MARK_OPENED_OVER_OPENED | MARK_CLOSED_OVER_OPENED,
    MARK_OVER_CLOSED = MARK_OPENED_OVER_CLOSED | MARK_CLOSED_OVER_CLOSED,
    MARK_OVER_ALL = MARK_OVER_OPENED | MARK_OVER_CLOSED,
}

var rng: RandomNumberGenerator
var opened_tiles := PointSet.new()
var closed_tiles := PointSet.new()

var grid := {}
var marked := {}

var remembered := []
var position := Vector2.ZERO
var width := -1
var height := -1

func _init(r: RandomNumberGenerator=null):
    if r:
        rng = r
    else:
        rng = RandomNumberGenerator.new()

func start(w: int, h: int) -> void:
    opened_tiles.clear()
    closed_tiles.clear()
    grid.clear()
    remembered = []
    position = Vector2.ZERO
    width = w
    height = h
    for y in height:
        for x in width:
            closed_tiles.add(x, y)
            grid[Vector2(x, y)] = 0

func out_of_bounds(pos: Vector2) -> bool:
    return pos.x < 0 || pos.y < 0 || pos.x >= width || pos.y >= height

func percent_opened() -> float:
    return opened_tiles.length() / float(width * height)

func on_last() -> bool:
    return position == remembered[-1]

func on_opened() -> bool:
    return opened_tiles.hasv(position)

func on_closed() -> bool:
    return closed_tiles.hasv(position)

func remember() -> void:
    remembered.append(position)

func recall() -> void:
    position = remembered.pop_back()

func forget() -> void:
    remembered.pop_back()

func goto(x: int, y: int) -> void:
    position = Vector2(x, y)

func gotov(pos: Vector2) -> void:
    position = pos

func goto_random() -> void:
    position = Vector2(rng.randi_range(0, width - 1), rng.randi_range(0, height - 1))

func goto_random_opened() -> void:
    position = opened_tiles.random(rng)

func goto_random_closed() -> void:
    position = closed_tiles.random(rng)

func step(dx: int, dy: int) -> void:
    position += Vector2(dx, dy)

func stepv(delta: Vector2) -> void:
    position += delta

func step_weighted_last(weight: float) -> void:
    var target_angle := position.angle_to_point(remembered[-1])
    var sum := 0.0
    var weights := []
    var candidates := []
    for delta in DIR8:
        var cand = position + delta
        if out_of_bounds(cand):
            continue
        var cand_angle := position.angle_to_point(cand)
        weights.append(exp(weight * cos(cand_angle - target_angle)))
        candidates.append(cand)
        sum += weights[-1]
    var r := rng.randf() * sum
    for i in len(candidates):
        r -= weights[i]
        if r <= 0:
            position = candidates[i]
            break

func mark(tile: int=1) -> void:
    marked[position] = tile

func mark_plus(tile: int=1) -> void:
    mark(tile)
    for d in [-1, 1]:
        remember()
        step(0, d)
        mark(tile)
        recall()
        remember()
        step(d, 0)
        mark(tile)
        recall()

func mark_circle(radius: int, tile: int=1) -> void:
    for x in radius * 2:
        for y in radius * 2:
            var dx: int = x - radius
            var dy: int = y - radius
            if dx * dx + dy * dy >= radius * radius:
                continue
            remember()
            step(dx, dy)
            mark(tile)
            recall()


func commit(mark_over: int=MARK_OVER_ALL) -> void:
    for pos in marked:
        var tile: int = marked[pos]
        if tile > 0:
            if (opened_tiles.hasv(pos) && mark_over & MARK_OPENED_OVER_OPENED) || \
               (closed_tiles.hasv(pos) && mark_over & MARK_OPENED_OVER_CLOSED):
                grid[pos] = tile
                closed_tiles.rem(pos.x, pos.y)
                opened_tiles.add(pos.x, pos.y)
        else:
            if (opened_tiles.hasv(pos) && mark_over & MARK_CLOSED_OVER_OPENED) || \
               (closed_tiles.hasv(pos) && mark_over & MARK_CLOSED_OVER_CLOSED):
                grid[pos] = tile
                opened_tiles.rem(pos.x, pos.y)
                closed_tiles.add(pos.x, pos.y)
    marked.clear()

func cancel() -> void:
    marked.clear()

func debug_print() -> void:
    for y in height:
        var line = ""
        for x in width:
            var c = grid[Vector2(x, y)]
            if c > 0:
                line += "#"
            else:
                line += " "
        print(line)
