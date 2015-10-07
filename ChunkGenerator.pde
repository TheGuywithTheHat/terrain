import java.util.concurrent.Callable;

class ChunkGenerator implements Runnable {
  Chunk oldChunk;
  float distance;
  int mapX;
  int mapZ;
  
  ChunkGenerator(Chunk oldChunk, float distance, int mapX, int mapZ) {
    this.oldChunk = oldChunk;
    this.distance = distance;
    this.mapX = mapX;
    this.mapZ = mapZ;
  }
  
  @Override
  public void run() {
    Chunk newChunk = new Chunk(oldChunk, distance);
    map[mapZ][mapX] = newChunk;
  }
}