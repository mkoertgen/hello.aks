using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using parrot.Models;

namespace parrot.Hubs
{
    public class DaemonHub : Hub
    {
        private static List<Pod> Pods { get; }
        private static List<string> DeletedPods { get; }

        static DaemonHub()
        {
            Pods = new List<Pod>();
            DeletedPods = new List<string>();
        }

        private const string PodDeletedStatus = "Deleted";

        public override Task OnConnectedAsync()
        {
            Clients.All.SendAsync("clusterViewUpdated", Pods);
            return base.OnConnectedAsync();
        }

        public void AddPod(Pod pod)
        {
            if(!DeletedPods.Contains(pod.Name))
            {
                Pods.Add(pod);
            }
        }

        public void RemovePod(Pod pod)
        {
            Pods.Remove(GetPod(pod));
            DeletedPods.Add(pod.Name);
        }

        public void UpdatePod(Pod pod)
        {
            var podToUpdate = GetPod(pod);
            podToUpdate.Name = pod.Name;
            podToUpdate.Container = pod.Container;
            podToUpdate.NameSpace = pod.NameSpace;
            podToUpdate.Status = pod.Status;
        }

        private static Pod GetPod(Pod pod)
        {
            return Pods.First(x => x.Name == pod.Name);
        }

        public void ClearClusterView()
        {
            Pods.Clear();
            Clients.All.SendAsync("clusterViewUpdated", Pods);
        }

        public void UpdateClusterView(Pod pod)
        {
            // If the container image is "image:tag", strip the ":tag", otherwise leave it alone
            // not all images are tagged, so..
            if(pod.ContainerImage.Contains(':'))
                pod.ContainerImage = pod.ContainerImage.Substring(0, pod.ContainerImage.IndexOf(':'));

            if (Pods.Any(x => x.Name == pod.Name))
                if (pod.Action == PodDeletedStatus)
                    RemovePod(pod);
                else
                    UpdatePod(pod);
            else
                AddPod(pod);

            Clients.All.SendAsync("clusterViewUpdated", Pods);
        }
    }
}