import { Badge } from "@shadcn/ui";

const TrackersCard = () => {
  return (
    <div className="p-6 bg-white rounded-lg shadow-md">
      <p>Trackers connected:</p>
      <Badge className="bg-green-200 text-green-800">3 active connections</Badge>
    </div>
  );
};

export default TrackersCard;
