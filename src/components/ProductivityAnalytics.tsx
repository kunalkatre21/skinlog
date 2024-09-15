import { Card } from "@shadcn/ui";
import { Line } from "react-chartjs-2";

const ProductivityAnalytics = () => {
  const data = {
    labels: ["Aug", "Sep", "Oct", "Nov"],
    datasets: [
      {
        label: "Focus Levels",
        data: [40, 50, 60, 80],
        fill: false,
        borderColor: "rgba(75, 192, 192, 1)",
        borderWidth: 2,
      },
    ],
  };

  return (
    <Card className="p-6">
      <h3 className="text-lg font-semibold mb-4">Focusing</h3>
      <Line data={data} options={{ responsive: true }} />
    </Card>
  );
};

export default ProductivityAnalytics;
