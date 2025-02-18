import ProfileSection from "./ProfileSection";
import TaskCard from "./TaskCard";
import TrackersCard from "./TrackersCard";
import ProductivityAnalytics from "./ProductivityAnalytics";
import MeetingsList from "./MeetingsList";
import DevelopedAreas from "./DevelopedAreas";
import NotificationsCard from "./NotificationsCard";
import ProfileCard from "./ProfileCard"; // Added ProfileCard import

const DashboardLayout = () => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 p-6">
      <div className="col-span-1">
        <ProfileSection />
        <TaskCard />
        <TrackersCard />
        <ProfileCard /> {/* Added ProfileCard component */}
      </div>
      <div className="col-span-2">
        <ProductivityAnalytics />
        <MeetingsList />
      </div>
      <div className="col-span-1">
        <DevelopedAreas />
        <NotificationsCard />
      </div>
    </div>
  );
};

export default DashboardLayout;
