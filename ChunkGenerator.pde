import java.util.concurrent.Callable;

int lastFrame;

class ChunkGenerator implements Runnable {
  Chunk oldChunk;
  float distance;
  int mapX;
  int mapZ;
  int worldX;
  int worldZ;
  
  boolean regen;
  
  ChunkGenerator(Chunk oldChunk, float distance, int mapX, int mapZ) {
    this.oldChunk = oldChunk;
    this.distance = distance;
    this.mapX = mapX;
    this.mapZ = mapZ;
    regen = true;
  }
  
  ChunkGenerator(int worldX, int worldZ, float distance, int mapX, int mapZ) {
    this.distance = distance;
    this.mapX = mapX;
    this.mapZ = mapZ;
    this.worldX = worldX;
    this.worldZ = worldZ;
    regen = false;
  }
  
  @Override
  public void run() {
    Chunk newChunk;
    if(regen) {
      newChunk = new Chunk(oldChunk, distance);
    } else {
      newChunk = new Chunk(worldX, worldZ, distance);
    }
    map[mapZ][mapX] = newChunk;
    //println(frameCount - lastFrame);
  }
}