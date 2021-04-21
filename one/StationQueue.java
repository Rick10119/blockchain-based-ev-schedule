package movement;


import core.DTNHost;
import core.SimClock;

import java.util.LinkedList;

/**
 * 每个充电站都要维护这么一个队列，队列的每一个元素是一个EV. StationQueue 定义了queue的一些操作
 * 每一个EV存储该电动汽车对应的host地址（相当于ID）、要充电的电量、以及到达时间。
 */
public class StationQueue {

    /** 最大排队空间，现在不考虑这个问题 */
    /** 充电桩的数量 */
    private static final int ChargingSlots = 6;

    private  static final double avrEnergyToCharge = 30.0;

    /** 队列 */
    protected LinkedList<EV> queue;
    /** DTNHost to which this movement model is attached */
    protected DTNHost host;

    /** constructor
     * 绑定充电站对应的host */
    public StationQueue(DTNHost host) {
        this.queue = new LinkedList<EV>();
        this.host = host;
    }

    /**
     * 和replicate一起用，复制
     * @param sq
     */
    public StationQueue(StationQueue sq) {
        this.host = sq.getHost();
        this.queue = (LinkedList<EV>)sq.getQueue().clone();
    }


    public StationQueue replicate() {
        return new StationQueue(this);
    }

    /**
     * 每一个排队的元素。存下其host句柄，但是不用单独存下要充的电量，而只是在host.java中修改
     * 但是在计算预计排队时间的时候需要计算
     */
    static class EV {
        // Fields
        DTNHost host;
        double energyToCharge;//随着充电进行而减小
        double arriveTime;//TODO: 利用估计的到达时间进行排队时间估计

        // constructor
        /** 生成队列元素的时候，host地址和电量需要输入，到达时间以SimClock为准 */
        public EV(DTNHost host,double energyToCharge){
            this.host = host;
            this.energyToCharge = energyToCharge;
            this.arriveTime = SimClock.getTime();
        }

        public EV(double energyToCharge) {
            this.host = null;
            this.energyToCharge = energyToCharge;
        }


        @Override
        public String toString() {
            return "EV{" +
                    "host=" + host +
                    "chargingHost= " + host.getChargingHost() +
                    ", energyToCharge=" + host.getEnergyToCharge() +
                    ", chargingStatus=" + host.getChargingStatus() +
                    ", arriveTime(min)=" + arriveTime/60.0 +
                    '}';
        }
    }


    /**
     * @return the host
     */
    public DTNHost getHost() {
        return this.host;
    }
    /**
     * @param host the host to set
     */
    public void setHost(DTNHost host) {
        this.host = host;
    }
    /** 添加一个新的EV元素(入队) */
    public boolean addQueue(DTNHost host, double energyToCharge) {

            // 可以排队，创建新的元素并排到队尾
            EV ev = new EV(host, energyToCharge);

            this.queue.offer(ev);


            // 或者在update()里面设置开始充电，如果直接充电，状态设为3
            upDate();

            // 报告状态
            ev.host.report();

        return true;
    }


    public int getQueueSize() {
        return this.queue.size();
    }

    public LinkedList<EV> getQueue() {
        return this.queue;
    }



    /**
     *
     * 更新队列情况，把还在排队的、充电桩数量内的电动汽车设为充电状态
     * 只会在入队、出队的时候做
     */
    public void upDate(){
        for (int i = 0;i < this.queue.size();i++) {

            // 把小于充电桩数量的车辆设置为充电状态。那些0状态的是路上的
            if(i < this.ChargingSlots) {
                if(this.queue.get(i).host.getChargingStatus() == 2){
                    this.queue.get(i).host.setChargingStatus(3);
                    this.queue.get(i).arriveTime = SimClock.getTime();
                }
            }
        }
        // 打印队列情况
//        System.out.println("充电站队列情况： ");
//        for (int i = 0;i < this.queue.size();i++) {
//
//            System.out.println(queue.get(i).toString());
//        }

//        System.out.println("充电站队列长度： "+queue.size());
    }

    /** 根据host对象句柄去除相应的车 */
    public void deQueue(DTNHost host) {
        EV object = null;
        for (EV ev : this.queue) {

            if (ev.host == host) {
                object = ev;
            }
        }
        this.queue.remove(object);

        upDate();
    }

    /**
     * 把已预约的车辆也放入队列。本来应该按照到达顺序，但是由于可能导致无法反悔，所以以预约顺序而不是达到顺序来决定。
     * 但是在预约状态的车辆不能充电，需要到达才行。
     * @param host
     * @param arriveTime
     * @return
     */
    public boolean reserve(DTNHost host, double arriveTime) {
        return this.addQueue(host, arriveTime);
    }


    /**
     * 获得目前队列中待充电量最少的汽车 ，并且把所有汽车都减去这个电量
     * 如果有汽车充完电，那么要移出去
     * @return
     */
    public double getMinEnergyToCharge() {
        double minEtoC = avrEnergyToCharge;

        // 获得当前最小的电量
        for (int i = 0;i < this.queue.size();i ++) {
            if(this.queue.get(i).energyToCharge < minEtoC) {
                minEtoC = this.queue.get(i).energyToCharge;
            }
        }

        // 所有电量减去最小电量；如果充完，就移出去。没充完的减去这个
        for (int i = 0;i < StationQueue.ChargingSlots && i < this.getQueueSize();i ++) {

            if(this.queue.get(i).energyToCharge < minEtoC + 0.01) {
                this.queue.remove(i);
                //移出去的时候，后面的队列的编号都少了1
                i --;
            } else {
                this.queue.get(i).energyToCharge -= minEtoC;
            }
        }

        return minEtoC;
    }

    /**
     * 根据输入的预计到达时间a，估计到达后将要等待的时间。
     * 计算有充电桩空出来的时间t，如果t比a小，那么不需要等，否则等待t-a
     * 已预约的车辆按照平均电量计算
     * @param arriveTime
     * @return
     */
    public double getWaitTime(double arriveTime) {

        if(this.getQueueSize() < ChargingSlots) {
            return 0;
        }

        // 新建一个stationQueue来计算
        StationQueue sq = new StationQueue(host);

        // 通过queue 的 EV 的host来访问到对应的充电站，从而获得充电站的lambda信息
        StationMovement sm = (StationMovement)(this.host.getMovement());
//        double lambda = sm.getLambdaK((int) Math.floor(arriveTime / (15 * 60)));

        // 读取现在车辆的充电情况，加入新的队列；
        for(int i = 0;i < this.getQueueSize();i++) {
            EV ev = new EV(this.queue.get(i).host.getEnergyToCharge());

            sq.getQueue().offer(ev);
        }


//        // 加上预测会到的车辆 TODO: 可能需要概率化的修正
//        int evToCome = (int) Math.floor((arriveTime - SimClock.getTime()) * lambda);
//        for(int i = this.getQueueSize();i < StationQueue.MaxQueue;i++) {
//            if(i < this.getQueueSize() + evToCome) {
//                EV ev = new EV(avrEnergyToCharge);
//                sq.getQueue().add(ev);
//            }
//        }


        // 新建好了，现在用sq来计算
        double availableTime = SimClock.getTime();
        while(sq.getQueueSize() >= 6) {
            // 更新时间,加上能量除以充电速率（kWh/s），
            availableTime = availableTime + sq.getMinEnergyToCharge()/DTNHost.chargingRate;
            // 更新电量 在getMinEnergyToCharge()中进行
        }

        // 返回时间
        if(arriveTime > availableTime) {
            // 如果在到达以前就可以充电，那么不用排队
            return 0.0;
        } else {
            // 否则，从到达时间等待到可以充电的时间
            return availableTime - arriveTime;
        }

    }

}
