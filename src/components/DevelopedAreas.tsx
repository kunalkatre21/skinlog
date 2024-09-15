import { Progress } from "@shadcn/ui";

const DevelopedAreas = () => {
  return (
    <div className="space-y-4">
      <div className="flex justify-between">
        <p>Sport Skills</p>
        <Progress value={71} className="w-full" />
      </div>
      <div className="flex justify-between">
        <p>Blogging</p>
        <Progress value={92} className="w-full" />
      </div>
      {/* Add more skills here */}
    </div>
  );
};

export default DevelopedAreas;
