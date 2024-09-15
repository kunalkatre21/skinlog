import { Card, List, ListItem } from "@shadcn/ui";

const NotificationsCard = () => {
  return (
    <Card className="p-6 space-y-4 shadow-md">
      <h3 className="text-lg font-semibold mb-4">Notifications</h3>
      <List>
        <ListItem>
          <div className="flex justify-between items-center">
            <div>
              <p className="text-sm font-semibold">New Message</p>
              <span className="text-xs text-muted">You have a new message from John Doe.</span>
            </div>
            <span className="text-xs text-muted">10 mins ago</span>
          </div>
        </ListItem>
        <ListItem>
          <div className="flex justify-between items-center">
            <div>
              <p className="text-sm font-semibold">Task Reminder</p>
              <span className="text-xs text-muted">Don't forget to complete the weekly report.</span>
            </div>
            <span className="text-xs text-muted">1 hour ago</span>
          </div>
        </ListItem>
        {/* Add more notifications here */}
      </List>
    </Card>
  );
};

export default NotificationsCard;
