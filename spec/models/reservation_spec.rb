# frozen_string_literal: true

describe Reservation, type: :model do
  it { is_expected.to belong_to(:listing) }

  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_presence_of(:end_date) }

  describe 'is after start' do
    context 'when the start_date is before the end_date' do
      let(:reservation) { build(:reservation, start_date: '2021-01-01', end_date: '2021-01-10') }

      it 'is valid' do
        reservation.validate
        expect(reservation.errors.details).to be_blank
      end
    end

    context 'when the start_date is after the end_date' do
      let(:reservation) { build(:reservation, start_date: '2021-01-10', end_date: '2021-01-01') }

      it 'is not valid' do
        reservation.validate
        expect(reservation.errors.details)
          .to eq({ start_date: [{ error: :greater_than_end_date }] })
      end
    end
  end

  context 'when there is already a reservation on these dates' do
    let!(:listing) { create(:listing) }
    let(:reservation_2) do
      build(:reservation, start_date: 3.days.from_now, end_date: 4.days.from_now, listing: listing)
    end

    before do
      create(:reservation, start_date: 2.days.from_now, end_date: 7.days.from_now, listing: listing)
    end

    it 'adds errors for overlapping other reservation' do
      reservation_2.validate
      expect(reservation_2.errors.details)
        .to eq({ start_date: [{ error: :overlap }], end_date: [{ error: :overlap }] })
    end
  end

  context 'when an other reservation has the same start_date and last_date on the listing' do
    let!(:listing) { create(:listing) }
    let(:reservation_2) do
      build(:reservation, start_date: 2.days.from_now, end_date: 4.days.from_now, listing: listing)
    end

    before do
      create(:reservation, start_date: 2.days.from_now, end_date: 4.days.from_now, listing: listing)
    end

    it 'adds errors uniquess of listing index' do
      reservation_2.validate
      expect(reservation_2.errors.details)
        .to eq({ listing_id: [{ error: :taken, value: 1 }],
                 start_date: [{ error: :overlap }], end_date: [{ error: :overlap }] })
    end
  end
end