package movement;

import core.DTNHost;
import core.Settings;
import core.SimClock;
import movement.map.DijkstraPathFinder;
import movement.map.MapNode;
import movement.map.PointsOfInterest;

import javax.swing.text.html.StyleSheet;
import java.util.List;
import java.util.Random;

public class ChangeTime extends MapBasedMovement {

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
    private double beta_TT = -6;// 每15分钟的时间成本（￥），北京市每小时24元
    private double beta_SDE = -10;// 提前15分钟出发的成本（取相反数）
    private double beta_SDL = -10;// 延后15分钟出发的成本

    // 构造器和父类一样。需要覆盖：选择路径的方法

    /**
     * Creates a new movement model based on a Settings object's settings.
     *
     * @param settings The Settings object where the settings are read from
     */
    public ChangeTime(Settings settings) {
        super(settings);

        this.pathFinder = new DijkstraPathFinder(getOkMapNodeTypes());
        this.pois = new PointsOfInterest(getMap(), getOkMapNodeTypes(),
                settings, rng);
        this.backAllowed = true;

        Random rng = new Random();// 产生随机数
        this.beta_SDL = -2.0 -1.0 * rng.nextDouble();
        this.beta_SDE = -2.0 -1.0 * rng.nextDouble();
        this.beta_TT = -3 -6.0 * rng.nextDouble();
    }

    /**
     * Copy constructor.
     *
     * @param mbm The ChargingMovement prototype to base
     *            the new object to
     */
    public ChangeTime(ChangeTime mbm) {
        super(mbm);
        this.pathFinder = mbm.pathFinder;
        // TODO: 这个初始化的方式要和sp一样（在settings里面）
        this.pois = mbm.pois;
        this.beta_TT = mbm.beta_TT;
        this.beta_SDE = mbm.beta_SDE;
        this.beta_SDL = mbm.beta_SDL;
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
        return  SimClock.getTime() + generateWaitTime() + getDeferTime();
    }

    /** 返回行程变更时间，用于时间均衡。 */
    private double getDeferTime() {

        // 针对初始化的修正
        if(null == this.host) {
            return 0.0;
        }

        // 原定抵达时间，但是大概15min要前往充电站。
        int T0 = (int) Math.floor(this.minWaitTime/(15.0 * 60.0));
        int queryT;

        // 通过充电站查询预测的lambdaK值,先返回充电站句柄，然后查询。所有充电站都一样，因此用0号的
        StationMovement MM = (StationMovement)this.host.getScenario().getHosts().get(0).getMovement();

        // 最多允许前后变动1一小时,获得最小的lambdaK
        int maxChangeT = 0;//变动的时间段
        double utility;
        // 初始化用户效用函数
        double maxUtility = calculateUtility(MM.getMeanWaitTime(T0), MM.queryPrice(T0), 0) ;


        for(int changeT = -4;changeT <= 4;changeT++) {
            // 变动后的时间
            queryT = T0 + changeT;
            if(queryT < 0 || queryT > 96) {
                //超出查找范围
                continue;
            }

            // 根据查询计算对应的效用函数
            utility = calculateUtility(MM.getMeanWaitTime(queryT), MM.queryPrice(queryT), changeT);
//            System.out.println(host.getName() + "当前效用函数" + utility);
//            System.out.println(host.getName() + "查询时间段、等待时间："+ queryT + " " + MM.getMeanWaitTime(queryT));
            // 查询对应的lambda值
            if(maxUtility < utility) {
                maxUtility = utility;
                maxChangeT = changeT;
            }
        }
//        if(maxChangeT != 0) {
//            System.out.println("最大时段改变" + maxChangeT);
//        }

        // 购买时段充电权
        MM.buy(T0 + maxChangeT);

        this.host.setChargingStatus(0);
        // 返回变动时间
//        return 0.0;
//        System.out.println(host.getName() + "改变时间" + maxChangeT);
        return maxChangeT * 15.0 * 60.0;
    }

    /** 计算用户效用 */
    private double calculateUtility(double WaitTime, double Price, int ChangeT) {
        // 时间单位转换为15分钟
        double SDE, SDL, TT;

        // 计算改变量
        SDL = Math.max(ChangeT, 0);
        SDE = Math.max(-ChangeT, 0);
        TT = WaitTime/(15.0);

        double utility = beta_SDE * SDE + beta_SDL * SDL + beta_TT * TT - Price;

        return  utility;

    }

    // 查询选择充电站和最短路径
    @Override
    public Path getPath() {
        if (this.host.getChargingStatus() != 0) {
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
        int MinIndex = -1;
        double MinCost = -1;// 初始化为-1

        MapNode stationNode;
        List<MapNode> nodePath1 = null, nodePath2 = null,
                MinNodePath1 = null, MinNodePath2 = null;

        // get all the hosts of the word
        List<DTNHost> hosts = host.getWorld().getHosts();

        double dist1, dist2;// the total distance of choosing a station， (m)
        double waitingTime, cost;// the price of the charging option

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

                // 发送查询请求,返回预计等待时间
                waitingTime = ((StationMovement) MM).getWaitingTime(arriveTime);
//                System.out.print("查询充电站： " + MM.getHost().getName() + "等待时间： " + waitingTime / 60.0);

                // 计算总成本并存储。排队时间成本加上两段的时间成本
                // TODO : 先考虑简单的，不考虑时间成本。这样看看分布。后面再看看平均多少行驶时间，多少钱
                cost =  - beta_TT * (waitingTime + (dist1 + dist2) / speed) / (15.0 * 60.0);

//                System.out.println(" 充电站： cost:" + cost);

                // 更新最低成本
                if (cost < MinCost || MinCost <= 0) {
                    MinCost = cost;
                    MinIndex = i;
                    MinArriveTime = arriveTime;
                    MinNodePath1 = nodePath1;
                    MinNodePath2 = nodePath2;
                }
            }
        }

        // 选择总成本最低的充电站，购买.(如果是-1表示没有找到充电站）
        if (MinIndex != -1) {
            // 选择成本最低的充电站,设置关联，并预约充电
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
    public ChangeTime replicate() {
        return new ChangeTime(this);
    }
}
