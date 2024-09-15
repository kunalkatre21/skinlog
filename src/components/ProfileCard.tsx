import { Avatar, Card, Progress } from "@shadcn/ui";

const ProfileCard = () => {
  return (
    <Card className="p-6 space-y-4 shadow-md">
      <div className="flex items-center space-x-4">
        <Avatar
          src="https://via.placeholder.com/60"
          alt="Kristin Watson"
          className="w-16 h-16"
        />
        <div>
          <h3 className="text-lg font-medium">Kristin Watson</h3>
          <p className="text-sm text-muted">Design Manager at XYZ Corp</p>
        </div>
      </div>
      <div className="space-y-2">
        <p className="text-sm font-semibold">Task Progress</p>
        <Progress value={83} className="w-full" />
      </div>
    </Card>
  );
};

export default ProfileCard;
