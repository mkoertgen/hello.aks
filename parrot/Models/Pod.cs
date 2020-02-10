namespace parrot.Models
{
    public class Pod
    {
        public string Name { get; set; }
        public string Container { get; set; }
        public string NameSpace { get; set; }
        public string ContainerImage { get; set; }
        public string Status { get; set; }
        public string Action { get; set; }
        public string CardImageUrl => $"/media/{Container}.png";

        public override string ToString() {
            return $"Name: {Name}\nContainer: {Container}\nNameSpace: {NameSpace}\nContainerImage: {ContainerImage}\nStatus: {Status}\nAction: {Action}\nCardImageUrl: {CardImageUrl}";
        }
    }
}