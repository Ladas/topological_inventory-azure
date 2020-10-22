require "topological_inventory/azure/operations/processor"

RSpec.describe TopologicalInventory::Azure::Operations::Processor do
  let(:message) { double("ManageIQ::Messaging::ReceivedMessage", :message => operation_name, :payload => payload) }
  let(:operation_name) { 'Testing.operation' }
  let(:params) { {'source_id' => 1, 'external_tenant' => '12345'} }
  let(:payload) { {"params" => params, "request_context" => double('request_context')} }

  subject { described_class.new(message, nil) }

  describe "#process" do
    context "Source.availability_check task" do
      let(:source_class) { TopologicalInventory::Azure::Operations::Source }
      let(:operation_name) { 'Source.availability_check' }

      it "runs availability check" do
        source = source_class.new(params)
        allow(source_class).to receive(:new).and_return(source)

        expect(source).to receive(:availability_check)

        subject.process
      end
    end
  end
end
