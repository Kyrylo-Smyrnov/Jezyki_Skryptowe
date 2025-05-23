player.onChat("buildCastle", function () {
    digMoatAroundWalls();
    buildTowers();
    buildWalls();
    buildBridge();
})

function buildTowers ()
{
    buildTower(20, -60, 20);
    buildTower(20, -60, -20);
    buildTower(-20, -60, -20);
    buildTower(-20, -60, 20);
}

function buildWalls()
{
    const y = -60;

    buildWall(20 + 3, y, 20, 20 + 3, -20);
    buildWall(20 - 3, y, -20, 20 - 3, 20);
    
    buildWall(-20, y, 20 + 3, 20, 20 + 3);
    buildWall(20, y, 20 - 3, -20, 20 - 3);
    
    buildWall(-20, y, -20 - 3, 20, -20 - 3);
    buildWall(20, y, -20 + 3, -20, -20 + 3);

    buildWall(-20 + 3, y, -20, -20 + 3, 20);
    buildWall(-20 - 3, y, 20, -20 - 3, -20);

    carveGates()
}

function buildTower(X: number, Y: number, Z: number) 
{
    let block = Block.Cobblestone;

    for (let y = 0; y < 14; y++)
    {
        for (let angle = 0; angle < 360; angle += 3)
        {
            const radians = angle * 3.1415 / 180;
            const x = Math.round(X + 4 * Math.cos(radians));
            const z = Math.round(Z + 4 * Math.sin(radians));

            blocks.place(block, world(x, Y + y, z));
        }
    }

    for (let y = 0; y < 4; y++)
    {
        let add = 3;

        if (y == 3)
        {
            add = 18;
            block = Block.CobblestoneWall;
        }
            
        for (let angle = 0; angle < 360; angle += add)
        {
            const radians = angle * 3.1415 / 180;
            const x = Math.round(X + (4 + 1) * Math.cos(radians));
            const z = Math.round(Z + (4 + 1) * Math.sin(radians));
            
            blocks.place(block, world(x, Y + 14 + y, z));
        }
    }

    block = Block.IronBars;
    const windowHeightStart = 10;

    const windowPositions = [
        { x: X, z: Z + 4 },
        { x: X, z: Z - 4 },
        { x: X + 4, z: Z },
        { x: X - 4, z: Z }
    ];

    for (const pos of windowPositions)
    {
        for (let yy = 0; yy < 3; yy++)
        {
            blocks.place(block, world(pos.x, Y + windowHeightStart + yy, pos.z));
        }
    }
}

function buildWall(X1: number, Y1: number, Z1: number, X2: number, Z2: number)
{
    const height = 10;
    const block = Block.Cobblestone;

    const xx = X2 - X1;
    const zz = Z2 - Z1;

    const length = Math.max(Math.abs(xx), Math.abs(zz));
    const stepX = xx / length;
    const stepZ = zz / length;

    for (let i = 0; i <= length; i++)
    {
        const x = Math.round(X1 + i * stepX);
        const z = Math.round(Z1 + i * stepZ);

        for (let y = 0; y < height; y++)
        {
            blocks.place(block, world(x, Y1 + y, z));
        }
    }
}

function carveGates()
{
    const y = -60;
    const archWidths = [8, 8, 6, 6, 4, 4, 2, 2];

    function carveArch(x: number, centerZ: number)
    {
        for (let yy = 0; yy < archWidths.length; yy++) 
        {
            const width = archWidths[yy];
            const half = Math.floor(width / 2);

            for (let dz = -half; dz < -half + width; dz++) 
            {
                blocks.place(Block.OakFence, world(x, y + yy, centerZ + dz));
            }
        }
    }

    carveArch(23, 0);
    carveArch(17, 0);
}

function digMoatAroundWalls()
{
    const y = -60;
    const Depth = 2;
    const Width = 9;

    const Z1 = 20 + 3;
    const Z2 = -20 - 3;
    const X1 = 20 + 3;
    const X2 = -20 - 3;

    const minX = X2 - Width;
    const maxX = X1 + Width;

    const minZ = Z2 - Width;
    const maxZ = Z1 + Width;

    for (let x = -32; x <= maxX; x++)
    {
        for (let z = Z1 + 1; z <= Z1 + Width; z++)
        {
            for (let yy = 0; yy > -Depth; yy--)
            {
                blocks.place(Block.Water, world(x, y + yy - 1, z));
            }
        }
    }
    for (let x = minX; x <= maxX; x++)
    {
        for (let z = Z2 - Width; z <= Z2 - 1; z++)
        {
            for (let yy = 0; yy > -Depth; yy--)
            {
                blocks.place(Block.Water, world(x, y + yy - 1, z));
            }
        }
    }
    for (let z = minZ; z <= maxZ; z++)
    {
        for (let x = X1 + 1; x <= X1 + Width; x++)
        {
            for (let yy = 0; yy > -Depth; yy--)
            {
                blocks.place(Block.Water, world(x, y + yy - 1, z));
            }
        }
    }
    for (let z = minZ; z <= maxZ; z++)
    {
        for (let x = X2 - Width; x <= X2 - 1; x++)
        {
            for (let yy = 0; yy > -Depth; yy--)
            {
                blocks.place(Block.Water, world(x, y + yy - 1, z));
            }
        }
    }
}

function buildBridge() {
    const y = -61;
    const posX = 24;
    const posZ = 4;

    for(let x = 0; x < 9; x++)
    {
        blocks.place(Block.OakFence, world(posX + x, y + 1, -5));

        for(let z = 0; z <= 9; z++)
        {
            blocks.place(Block.StrippedDarkOakWood, world(posX + x, y, posZ - z));
        }

        blocks.place(Block.OakFence, world(posX + x, y + 1, 4));
    }
}