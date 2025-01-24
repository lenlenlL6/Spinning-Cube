local mgl = require("libs.MGL")

mgl.require_vec(3)
mgl.require_vec(4)
mgl.require_mat(4, 4)

local fov = math.rad(60)
local aspect = love.graphics.getWidth() / love.graphics.getHeight()
local near, far = 0.1, 100

local projectionMatrix = mgl.perspective(fov, aspect, near, far)

local vertices = {
    mgl.vec3(-1, -1, -1),
    mgl.vec3( 1, -1, -1),
    mgl.vec3( 1,  1, -1),
    mgl.vec3(-1,  1, -1),
    mgl.vec3(-1, -1,  1),
    mgl.vec3( 1, -1,  1),
    mgl.vec3( 1,  1,  1),
    mgl.vec3(-1,  1,  1)
}

local edges = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Bottom face
    {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Top face
    {1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Vertical edges
}

-- love._openConsole()

function love.update(dt)
    local rotationMatrixX = mgl.rotate(mgl.vec3(1, 0, 0), math.rad(200 * dt))  
    local rotationMatrixZ = mgl.rotate(mgl.vec3(0, 0, 1), math.rad(100 * dt))  
    for i, point in ipairs(vertices) do
        local vect4 = mgl.vec4(point.x, point.y, point.z, 1)
        local rotatedVect4 = rotationMatrixX * rotationMatrixZ * vect4
        point.x = rotatedVect4.x
        point.y = rotatedVect4.y
        point.z = rotatedVect4.z
    end
end

function love.draw()
    for _, edge in ipairs(edges) do
        local point1 = vertices[edge[1]]
        local viewMatrix = mgl.translate(mgl.vec3(0, 0, -5))
        point1 = viewMatrix * mgl.vec4(point1.x, point1.y, point1.z, 1)
        local homogeneousPoint1 = mgl.vec4(point1.x, point1.y, point1.z, 1)
        local projectedPoint1 = projectionMatrix * homogeneousPoint1
        if projectedPoint1.w ~= 0 then
            projectedPoint1.x = projectedPoint1.x / projectedPoint1.w
            projectedPoint1.y = projectedPoint1.y / projectedPoint1.w
            projectedPoint1.z = projectedPoint1.z / projectedPoint1.w
        end
        local screenP1 = mgl.vec3(
            (projectedPoint1.x * 0.5 + 0.5) * love.graphics.getWidth(),
            (1 - (projectedPoint1.y * 0.5 + 0.5)) * love.graphics.getHeight(),
            projectedPoint1.z
        )

        local point2 = vertices[edge[2]]
        point2 = viewMatrix * mgl.vec4(point2.x, point2.y, point2.z, 1)
        local homogeneousPoint2 = mgl.vec4(point2.x, point2.y, point2.z, 1)
        local projectedPoint2 = projectionMatrix * homogeneousPoint2
        if projectedPoint2.w ~= 0 then
            projectedPoint2.x = projectedPoint2.x / projectedPoint2.w
            projectedPoint2.y = projectedPoint2.y / projectedPoint2.w
            projectedPoint2.z = projectedPoint2.z / projectedPoint2.w
        end
        local screenP2 = mgl.vec3(
            (projectedPoint2.x * 0.5 + 0.5) * love.graphics.getWidth(),
            (1 - (projectedPoint2.y * 0.5 + 0.5)) * love.graphics.getHeight(),
            projectedPoint2.z
        )

        love.graphics.line(screenP1.x, screenP1.y, screenP2.x, screenP2.y)
    end
end
