import { List, ListItem, Badge } from "@shadcn/ui";

const MeetingsList = () => {
  return (
    <List>
      <ListItem>
        <div className="flex justify-between items-center">
          <div>
            <p className="text-sm font-semibold">Quick Daily Meeting</p>
            <span className="text-xs text-muted">Tue, 11 Jul - 8:15 am</span>
          </div>
          <Badge className="bg-blue-100 text-blue-800">Zoom</Badge>
        </div>
      </ListItem>
      {/* Add more meetings here */}
    </List>
  );
};

export default MeetingsList;
