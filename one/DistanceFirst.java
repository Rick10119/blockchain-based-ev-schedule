package movement;

import core.DTNHost;
import core.Settings;
import core.SimClock;
import movement.map.DijkstraPathFinder;
import movement.map.MapNode;
import movement.map.PointsOfInterest;

import java.util.List;

public class DistanceFirst extends MapBasedMovement {

    /**
     * the Dijkstra shortest path finder
     */
    private DijkstraPathFinder pathFinder;
    /**
     * Points Of Interest handler
     */
    private PointsOfInterest pois;
    /**
     * The special setting of the EV
     */
    // TODO: 后面可以把这个时间成本随机化。还有就是位置的初始化
    private final double w = 6;// 每15分钟的时间成本（￥），北京市每小时24元

    // 构造器和父类一样。需要覆盖：选择路径的方法
    /**
     * Creates a new movement model based on a Settings object's settings.
     *
     * @param settings The Settings object where the settings are read from
     */
    public DistanceFirst(Settings settings) {
        super(settings);

        this.pathFinder = new DijkstraPathFinder(getOkMapNodeTypes());
        this.pois = new PointsOfInterest(getMap(), getOkMapNodeTypes(),
                settings, rng);
        this.backAllowed = true;
    }

    /**
     * Copy constructor.
     *
     * @param mbm The DistanceFirst prototype to base
     *            the new object to
     */
    protected DistanceFirst(DistanceFirst mbm) {
        super(mbm);
        this.pathFinder = mbm.pathFinder;
        // TODO: 这个初始化的方式要和sp一样（在settings里面）
        this.pois = mbm.pois;
    }

    /**
     * Returns a sim time when the next path is available. This implementation
     * returns a random time in future that is {@link #WAIT_TIME} from now.
     * @return The sim time when node should ask the next time for a path
     */
    @Override
    public double nextPathAvailable() {
        if(this.host.getChargingStatus() != -2) {
            return  SimClock.getTime() + generateWaitTime();
        }
        this.host.setChargingStatus(0);
        return  SimClock.getTime() + generateWaitTime();
    }

    @Override
    public Path getPath() {
        if(host.getChargingStatus()!=0) {
            return null;
        }
        // 生成一个速度，这个速度只在这一段path里面有用。下一段还会重新生成。or： 在初始化的时候一起生成
        double speed = generateSpeed(); // (m/s)
        // 生成一个空的path用来存路线
        Path p = new Path(speed);
        // 用poi的函数随机选一个目的地。
        MapNode to = pois.selectDestination();

        // 访问静态字段
        double currentTime = SimClock.getTime();
        double arriveTime, MinArriveTime = 0;
        int T1, T2;
        int MinIndex = -1, MinT1 = 0, MinT2 = 0;
        double MinCost = -1, MinPrice = -1;// 初始化为-1

        MapNode stationNode;
        List<MapNode> nodePath1 = null, nodePath2 = null,
                MinNodePath1 = null, MinNodePath2 = null;

        // get all the hosts of the word
        List<DTNHost> hosts = host.getWorld().getHosts();

        double dist1, dist2;// the total distance of choosing a station， (m)
        double price, cost;// the price of the charging option

        MovementModel MM;


        // 遍历所有的host，查询
        for (int i = 0; i < StationMovement.getL(); i++) {
            // 获取host的类型，对所有充电站进行查询，并获得最低总成本充电站
            // TODO: 如果在setting里面按顺序写，就不用全部遍历host，节约时间
            // TODO: 考虑要不要购买充电权，那就是返回预计等待时间和价格，相对比。
            MM = hosts.get(i).getMovement();
            if (MM instanceof StationMovement) {
//                (StationMovement) MM.
                // 返回充电站的地点
                stationNode = ((StationMovement) MM).getMapNode();


                // 得到从这里到充电站以及从充电站到目的地的路线和总路程
                nodePath1 = pathFinder.getShortestPath(lastMapNode, stationNode);
                nodePath2 = pathFinder.getShortestPath(stationNode, to);
                dist1 = pathFinder.getPathDistance(nodePath1);
                dist2 = pathFinder.getPathDistance(nodePath2);


                // 计算到达充电站时间, 现在的时间加上第一段时间
                arriveTime = dist1 / speed + currentTime;

                // 决定要购买的充电权 T1,假设充半小时， T2 = T1 + 2；
                // T的slot是15min，而这里单位是s，因此应该用 Math.floor(time/ (60*15))
                T1 = (int) Math.floor(arriveTime / (15 * 60));
                T2 = T1 + 2;


                // 计算总成本并存储。充电权成本加上两段的时间成本
                // TODO : 先考虑简单的，不考虑时间成本。这样看看分布。后面再看看平均多少行驶时间，多少钱
                cost =  w / (15.0 * 60.0) * (dist1 + dist2) / speed;

                // 更新最低成本
                if (cost < MinCost || MinCost <= 0) {
                    MinCost = cost;
                    MinIndex = i;
                    MinArriveTime = arriveTime;
                    MinT1 = T1;
                    MinT2 = T2;
                    MinNodePath1 = nodePath1;
                    MinNodePath2 = nodePath2;
                }
            }
        }

        // 选择总成本最低的充电站，购买.(如果是-1表示没有找到充电站）
        if (MinIndex != -1) {
            // 选择成本最低的充电站,设置关联，并购买充电权
            this.host.setChargingHost(hosts.get(MinIndex));
            boolean ok = ((StationMovement) hosts.get(MinIndex).getMovement()).reserve(this.host, MinArriveTime);

            // for test.
//            MM = hosts.get(MinIndex).getMovement();

//            System.out.println("\nEV编号：" + this.host.getName());
//            System.out.println("充电状态： "+ this.host.getChargingStatus());
//            System.out.println("选择充电站编号：" + MinIndex);
//            System.out.println("充电权价格：" + MinPrice);
//            System.out.println("现在时刻：" + currentTime);
//            System.out.println("到达时刻：" + MinArriveTime);
//            System.out.println("T1：" + MinT1);
//            System.out.println("T2：" + MinT2);
        }


        // this assertion should never fire if the map is checked in read phase
        assert MinNodePath1.size() > 0 : "No path from " + lastMapNode + " to " +
                to + ". The simulation map isn't fully connected";
        for (MapNode node : MinNodePath1) { // create a Path from the shortest path
            p.addWaypoint(node.getLocation());
        }


        assert MinNodePath2.size() > 0 : "No path from " + lastMapNode + " to " +
                to + ". The simulation map isn't fully connected";
        for (int i = 1; i < MinNodePath2.size(); i++) { // create a Path from the shortest path

            p.addWaypoint(MinNodePath2.get(i).getLocation());

        }

        lastMapNode = to;
        return p;
    }

    @Override
    public DistanceFirst replicate() {
        return new DistanceFirst(this);
    }
}
